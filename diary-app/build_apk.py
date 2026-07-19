#!/usr/bin/env python3
"""나의 일기장 APK 빌드 스크립트 (aapt 없이 pyaxml + 순수 파이썬 서명)"""
import os, sys, struct, zipfile, hashlib, base64, datetime

PROJ = os.path.dirname(os.path.abspath(__file__))
TMP = '/tmp/apkbuild'
OUT_UNSIGNED = os.path.join(TMP, 'unsigned.apk')

MANIFEST_XML = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.kim.diary" android:versionCode="3" android:versionName="1.2">
    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="28"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:label="나의 일기장" android:icon="@7F010000" android:allowBackup="true">
        <activity android:name="com.kim.diary.MainActivity" android:exported="true" android:configChanges="0x000004B0" android:windowSoftInputMode="0x00000010">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>'''

# 안정성 우선 매니페스트: 아이콘 리소스 참조 없음(기본 아이콘 사용) → resources.arsc 불필요
MANIFEST_NOICON = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.kim.diary" android:versionCode="3" android:versionName="1.2">
    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="28"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:label="나의 일기장" android:allowBackup="true">
        <activity android:name="com.kim.diary.MainActivity" android:exported="true" android:configChanges="0x000004B0" android:windowSoftInputMode="0x00000010">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>'''

def build_manifest(xml=None):
    from pyaxml import AXML
    a = AXML()
    a.from_xml(xml if xml is not None else MANIFEST_XML)
    a.compute()
    return a.pack()

def build_arsc():
    from pyaxml.proto import axml_pb2
    from pyaxml import ARSC
    def pool():
        sb = axml_pb2.StringBlocks()
        sb.hnd.hnd.type = 0x0001
        sb.hnd.hnd.header_size = 28
        sb.hnd.flag = (1 << 8)
        return sb
    p = axml_pb2.ARSC()
    p.header_res.hnd.type = 0x0002
    p.header_res.hnd.header_size = 12
    p.header_res.package_count = 1
    pkg = p.restablespackage.add()
    pkg.hnd.type = 0x0200
    pkg.hnd.header_size = 288
    pkg.id = 0x7f
    pkg.name = 'com.kim.diary'
    pkg.type_sp_string.CopyFrom(pool())
    pkg.key_sp_string.CopyFrom(pool())
    p.stringblocks.CopyFrom(pool())
    arsc = ARSC.from_proto(p)
    rid = arsc.add_id_public(None, 'drawable', 'ic_launcher', 'res/ic_launcher.png')
    assert rid == 0x7F010000, hex(rid)
    arsc.compute()
    return arsc.pack()

def make_zip(files):
    if os.path.exists(OUT_UNSIGNED):
        os.remove(OUT_UNSIGNED)
    with zipfile.ZipFile(OUT_UNSIGNED, 'w', zipfile.ZIP_DEFLATED) as z:
        for name, data in files.items():
            zi = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            zi.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(zi, data)

# ---------------- v1 (JAR) signing ----------------
def b64(d):
    return base64.b64encode(d).decode()

def mf_section(pairs):
    out = ''
    for k, v in pairs:
        out += k + ': ' + v + '\r\n'
    return out + '\r\n'

def sign_v1(unsigned_path, signed_path, key_pem_path):
    from cryptography import x509
    from cryptography.x509.oid import NameOID
    from cryptography.hazmat.primitives import hashes, serialization
    from cryptography.hazmat.primitives.asymmetric import rsa, padding
    from cryptography.hazmat.primitives.serialization import pkcs7

    # 키/인증서 재사용 또는 생성 (재빌드 시 같은 서명 유지 → 덮어쓰기 설치 가능)
    if os.path.exists(key_pem_path):
        key = serialization.load_pem_private_key(open(key_pem_path, 'rb').read(), None)
    else:
        key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        open(key_pem_path, 'wb').write(key.private_bytes(
            serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
            serialization.NoEncryption()))
    name = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, 'Kim Diary'),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, 'Personal'),
    ])
    now = datetime.datetime(2026, 1, 1)
    cert = (x509.CertificateBuilder()
            .subject_name(name).issuer_name(name)
            .public_key(key.public_key())
            .serial_number(1)
            .not_valid_before(now)
            .not_valid_after(now + datetime.timedelta(days=365 * 30))
            .sign(key, hashes.SHA256()))

    zin = zipfile.ZipFile(unsigned_path, 'r')
    entries = [(n, zin.read(n)) for n in zin.namelist()]

    # MANIFEST.MF
    mf = mf_section([('Manifest-Version', '1.0'), ('Created-By', '1.0 (Android)')])
    sections = {}
    for n, data in entries:
        sec = mf_section([('Name', n), ('SHA-256-Digest', b64(hashlib.sha256(data).digest()))])
        sections[n] = sec
        mf += sec
    mf_bytes = mf.encode()

    # CERT.SF
    sf = mf_section([
        ('Signature-Version', '1.0'),
        ('Created-By', '1.0 (Android)'),
        ('SHA-256-Digest-Manifest', b64(hashlib.sha256(mf_bytes).digest())),
    ])
    for n, _ in entries:
        sf += mf_section([('Name', n),
                          ('SHA-256-Digest', b64(hashlib.sha256(sections[n].encode()).digest()))])
    sf_bytes = sf.encode()

    # CERT.RSA (PKCS#7 detached signature over CERT.SF)
    p7 = (pkcs7.PKCS7SignatureBuilder()
          .set_data(sf_bytes)
          .add_signer(cert, key, hashes.SHA256())
          .sign(serialization.Encoding.DER,
                [pkcs7.PKCS7Options.DetachedSignature,
                 pkcs7.PKCS7Options.Binary,
                 pkcs7.PKCS7Options.NoAttributes]))

    if os.path.exists(signed_path):
        os.remove(signed_path)
    with zipfile.ZipFile(signed_path, 'w', zipfile.ZIP_DEFLATED) as z:
        def w(name, data):
            zi = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            z.writestr(zi, data)
        w('META-INF/MANIFEST.MF', mf_bytes)
        w('META-INF/CERT.SF', sf_bytes)
        w('META-INF/CERT.RSA', p7)
        for n, data in entries:
            w(n, data)
    zin.close()

def main():
    os.makedirs(TMP, exist_ok=True)
    safe = '--safe' in sys.argv or os.environ.get('SAFE_MODE')
    dex_path = os.path.join(PROJ, 'build/apk/classes.dex')
    if not os.path.exists(dex_path):
        dex_path = '/tmp/proj/build/apk/classes.dex'
    files = {}
    if safe:
        # 아이콘/리소스 테이블 없이 최대한 표준적으로 빌드
        files['AndroidManifest.xml'] = build_manifest(MANIFEST_NOICON)
    else:
        files['AndroidManifest.xml'] = build_manifest()
        files['resources.arsc'] = build_arsc()
        files['res/ic_launcher.png'] = open(os.path.join(PROJ, 'res/drawable-xxxhdpi/ic_launcher.png'), 'rb').read()
    files['classes.dex'] = open(dex_path, 'rb').read()
    files['assets/index.html'] = open(os.path.join(PROJ, 'assets/index.html'), 'rb').read()
    files['assets/marked.min.js'] = open(os.path.join(PROJ, 'assets/marked.min.js'), 'rb').read()
    make_zip(files)
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    signed = args[0] if args else os.path.join(TMP, 'diary-signed.apk')
    sign_v1(OUT_UNSIGNED, signed, os.path.join(PROJ, 'signing-key.pem'))
    print('OK signed ->', signed, os.path.getsize(signed), 'bytes')

if __name__ == '__main__':
    main()
