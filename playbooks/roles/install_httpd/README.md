# Ansible role `httpd`

A simple Ansible role for installing and configuring the Apache web server for RHEL/CentOS 8 and Fedora 28+. Specifically, the responsibilities of this role are to:

- Install the necessary packages;
- Maintain the main configuration file;
- Maintain the configuration file for `mod_ssl`. The default settings are based on the recommendations of [Mozilla's SSL Configuration Generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=apache-2.4.34&openssl=1.1.0i&hsts=yes&profile=modern);
- Install custom certificate files;
- Enable and maintain the configuration file for `mod_status`.
- Configure firewalld (if installed and running)

Currently, no virtual hosts or other features are provided.

## Requirements

- No requirements.

## Dependencies

No dependencies.

## Role Variables

None of the variables below are required

| Variable                                     | Default                       | Comments                                                                                |
| :---                                         | :---                          | :---                                                                                    |
| `httpd_access_log`                           | logs/access_log               | Location of the access log file (http)                                                  |
| `httpd_access_log_ssl`                       | logs/ssl_access_log           | Location of the access log file (https)                                                 |
| `httpd_document_root`                        | '/var/www/html'               | Path to the document root (directory containing html files)                             |
| `httpd_error_log`                            | logs/error_log                | Location of the error log file (http)                                                   |
| `httpd_error_log_ssl`                        | logs/ssl_error_log            | Location of the error log file (https)                                                  |
| `httpd_extended_status`                      | on                            | Enable extended status info (see `httpd_status_enable`)                                 |
| `httpd_listen_ssl`                           | 443                           | Port number for https connections                                                       |
| `httpd_listen`                               | 80                            | Port number for http connections                                                        |
| `httpd_log_level_ssl`                        | warn                          | [Verbosity of the https logs](https://httpd.apache.org/docs/2.4/mod/core.html#loglevel) |
| `httpd_log_level`                            | warn                          | [Verbosity of the http logs](https://httpd.apache.org/docs/2.4/mod/core.html#loglevel)  |
| `httpd_server_admin`                         | root@localhost                | E-mail address of the server administrator                                              |
| `httpd_server_name`                          | -                             | Hostname that the server uses to identify itself                                        |
| `httpd_server_root`                          | '/etc/httpd'                  | Directory containing configuration files                                                |
| `httpd_server_tokens`                        | Prod                          | See [documentation](https://httpd.apache.org/docs/current/mod/core.html#servertokens)   |
| `httpd_ssl_ca_certificate_file`              | -                             | Name of a CA certificate file. See below, *Installing certificates*                     |
| `httpd_ssl_certificate_chain_file`           | -                             | Name of a certificate chain file. See below, *Installing certificates*                  |
| `httpd_ssl_certificate_file`                 | localhost.crt                 | Name of the certificate file. See below, *Installing certificates*                      |
| `httpd_ssl_certificate_key_file`             | localhost.key                 | Name of the certificate key file. See below, *Installing certificates*                  |
| `httpd_ssl_cipher_suite`                     | ...                           | See [default variables](defaults/main.yml)                                              |
| `httpd_ssl_compression`                      | 'off'                         | When 'on', enables compression on the SSL level (which may cause security issues)       |
| `httpd_ssl_honor_cipher_order`               | 'on'                          | When 'on', prefer the server's cipher preference order instead of the client's          |
| `httpd_ssl_protocol`                         | 'all -SSLv3 -TLSv1'           | Specifies usable SSL/TLS protocol versions                                              |
| `httpd_ssl_session_tickets`                  | 'off'                         | When 'on', enables use of TLS session tickets (which may cause security issues)         |
| `httpd_ssl_stapling_cache`                   | 'shmcb:/var/run/ocsp(128000)' | Configures the OCSP stapling cache (1)                                                  |
| `httpd_ssl_stapling_responder_timeout`       | 5                             | Timeout for OCSP stapling queries (1)                                                   |
| `httpd_ssl_stapling_return_responder_errors` | 'off'                         | When 'on', pass stapling related OCSP errors on to client (1)                           |
| `httpd_ssl_use_stapling`                     | 'on'                          | When 'on', enables stapling of OCSP responses in the TLS handshake (1)                  |
| `httpd_status_enable`                        | false                         | Enable mod_status                                                                       |
| `httpd_status_location`                      | '/server-status'              | Location for mod_status status page                                                     |
| `httpd_status_require`                       | 'host localhost'              | Access control for mod_status                                                           |

(1) For more information on Online
      Certificate Status Protocol (OCSP) stapling, see the [Apache documentation](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslusestapling), and the section "Certificate Status Request" of [RFC 6066](https://tools.ietf.org/html/rfc6066.html)

## Installing certificates

By default, the role uses the self-signed certificate that is generated when installing `mod_ssl`. If you want to use a custom certificate, put it in a subdirectory named `files/`, relative to your main playbook location. Then set the appropriate role variables. For instructions on how to set up your own (self-signed) certificates, see e.g. the [CentOS Wiki](https://wiki.centos.org/HowTos/Https).

E.g. you have a server key `acme-inc.key` and certificate file `acme-inc.crt`. The directory structure should look:

```
.
├── playbook.yml
└── files
    ├── acme-inc.crt
    └── acme-inc.key
```

Then, define the role variables in the appropriate location (playbook `vars:` section, `group_vars`, or `host_vars`):

```yaml
httpd_ssl_certificate_key_file: 'acme-inc.key'
httpd_ssl_certificate_file: 'acme-inc.crt'
```

The same goes for a certificate chain file and CA certificate file. Ensure they are available in the `files/` directory, and define variables `httpd_ssl_certificate_chain_file`, and `httpd_ssl_ca_certificate_file`, respectively.

## License

2-clause BSD license, see [LICENSE.md](LICENSE.md)

## Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTE0OTI0OTY5MiwtNDk3NDUyNDJdfQ==
-->