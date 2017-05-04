patchwork:
  lookup:
    version: master
    secret_key: secret
    db_host: postgres
    admins:
        alice: alice@example.com
        bob: bob@example.com
    mail:
      address: patchwork@example.com
      server: imap.example.com
      port: 993
      username: patchwork
      password: krowhctap
      delete: false
