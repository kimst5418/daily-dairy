.class public Lcom/kim/diary/Bridge;
.super Ljava/lang/Object;
.source "Bridge.java"

.field private ctx:Landroid/content/Context;

.method public constructor <init>(Landroid/content/Context;)V
    .registers 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    return-void
.end method

.method public saveApp(Ljava/lang/String;)Z
    .registers 8
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start_0
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "app.html.tmp"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const-string v3, "UTF-8"
    invoke-virtual {p1, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;
    move-result-object v3
    invoke-virtual {v3}, Ljava/io/FileDescriptor;->sync()V
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    new-instance v2, Ljava/io/File;
    const-string v3, "app.html"
    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->delete()Z
    invoke-virtual {v1, v2}, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    return v0
    :catch_0
    move-exception v0
    const/4 v0, 0x0
    return v0
.end method

.method public clearApp()Z
    .registers 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start_0
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "app.html"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->delete()Z
    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    return v0
    :catch_0
    move-exception v0
    const/4 v0, 0x0
    return v0
.end method

.method public load()Ljava/lang/String;
    .registers 8
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start_0
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "diary.json"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :have_file
    new-instance v1, Ljava/io/File;
    const-string v2, "diary.bak"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v2
    if-nez v2, :have_file
    const-string v0, ""
    return-object v0
    :have_file
    new-instance v2, Ljava/io/FileInputStream;
    invoke-direct {v2, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    invoke-virtual {v1}, Ljava/io/File;->length()J
    move-result-wide v3
    long-to-int v3, v3
    new-array v4, v3, [B
    const/4 v5, 0x0
    :loop
    if-ge v5, v3, :loop_end
    sub-int v6, v3, v5
    invoke-virtual {v2, v4, v5, v6}, Ljava/io/FileInputStream;->read([BII)I
    move-result v6
    if-ltz v6, :loop_end
    add-int/2addr v5, v6
    goto :loop
    :loop_end
    invoke-virtual {v2}, Ljava/io/FileInputStream;->close()V
    new-instance v0, Ljava/lang/String;
    const/4 v1, 0x0
    const-string v2, "UTF-8"
    invoke-direct {v0, v4, v1, v5, v2}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    return-object v0
    :catch_0
    move-exception v0
    const-string v0, ""
    return-object v0
.end method

.method public save(Ljava/lang/String;)Z
    .registers 8
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start_0
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "diary.tmp"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const-string v3, "UTF-8"
    invoke-virtual {p1, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;
    move-result-object v3
    invoke-virtual {v3}, Ljava/io/FileDescriptor;->sync()V
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    new-instance v2, Ljava/io/File;
    const-string v3, "diary.json"
    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v3, Ljava/io/File;
    const-string v4, "diary.bak"
    invoke-direct {v3, v0, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->exists()Z
    move-result v4
    if-eqz v4, :do_rename
    invoke-virtual {v3}, Ljava/io/File;->delete()Z
    invoke-virtual {v2, v3}, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    :do_rename
    invoke-virtual {v1, v2}, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    return v0
    :catch_0
    move-exception v0
    const/4 v0, 0x0
    return v0
.end method

.method public backup(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 8
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start_0
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    if-nez v1, :have_dir
    iget-object v0, p0, Lcom/kim/diary/Bridge;->ctx:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v1
    :have_dir
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v1, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v3, Ljava/io/FileOutputStream;
    invoke-direct {v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const-string v4, "UTF-8"
    invoke-virtual {p2, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v4
    invoke-virtual {v3, v4}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v3}, Ljava/io/FileOutputStream;->close()V
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    return-object v0
    :catch_0
    move-exception v0
    const-string v0, ""
    return-object v0
.end method
