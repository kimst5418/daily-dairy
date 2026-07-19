.class public Lcom/kim/diary/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

.field private web:Landroid/webkit/WebView;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 6
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
    invoke-virtual {p0}, Lcom/kim/diary/MainActivity;->getActionBar()Landroid/app/ActionBar;
    move-result-object v0
    if-eqz v0, :no_ab
    invoke-virtual {v0}, Landroid/app/ActionBar;->hide()V
    :no_ab
    invoke-virtual {p0}, Lcom/kim/diary/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v0
    const v1, -0xc1629
    invoke-virtual {v0, v1}, Landroid/view/Window;->setStatusBarColor(I)V
    invoke-virtual {v0, v1}, Landroid/view/Window;->setNavigationBarColor(I)V
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    const v2, -0x50c19
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lcom/kim/diary/MainActivity;->web:Landroid/webkit/WebView;
    const v1, -0x50c19
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V
    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V
    new-instance v2, Lcom/kim/diary/Bridge;
    invoke-direct {v2, p0}, Lcom/kim/diary/Bridge;-><init>(Landroid/content/Context;)V
    const-string v3, "AndroidBridge"
    invoke-virtual {v0, v2, v3}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V
    invoke-virtual {p0}, Lcom/kim/diary/MainActivity;->getFilesDir()Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    const-string v3, "app.html"
    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->exists()Z
    move-result v1
    if-eqz v1, :use_asset
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "file://"
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    goto :do_load
    :use_asset
    const-string v3, "file:///android_asset/index.html"
    :do_load
    invoke-virtual {v0, v3}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    invoke-virtual {p0, v0}, Lcom/kim/diary/MainActivity;->setContentView(Landroid/view/View;)V
    return-void
.end method

.method public onBackPressed()V
    .registers 3
    iget-object v0, p0, Lcom/kim/diary/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :cond_super
    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z
    move-result v1
    if-eqz v1, :cond_super
    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V
    return-void
    :cond_super
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method
