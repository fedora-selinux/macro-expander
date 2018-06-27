# sepolicy-expander

Tool helps determinate what raw allow rules will be enabled using specific selinux policy m4 macro.
Geneterated output is in CIL representation or in policy source (.te) format.

## Usage

    ./sepolicy-expander.sh [ -c | -t [ -M ] ] <macro>
    Options:
      -c     generate CIL output - this is default
      -t     generate standard policy source format (.te) allow rules
      -M     generate complete module .te output

    ./sepolicy-expander.sh "NAME_OF_MACRO(SELINUX_DOMAIN)"

## Example

    $ git clone https://github.com/wrabcak/sepolicy-expander.git
    $ cd sepolicy-expander

    $ ./sepolicy-expander.sh "apache_read_log(mysqld_t)"
    (allow mysqld_t httpd_log_t (dir (getattr search open)))
    (allow mysqld_t httpd_log_t (dir (ioctl read getattr lock search open)))
    (allow mysqld_t httpd_log_t (file (ioctl read getattr lock open)))
    (allow mysqld_t httpd_log_t (lnk_file (read getattr)))
    (allow mysqld_t var_log_t (dir (getattr search open)))
    (allow mysqld_t var_t (dir (getattr search open)))

    $ ./sepolicy-expander.sh -t "apache_read_log(mysqld_t)"
    allow mysqld_t var_t:dir { getattr search open };
    allow mysqld_t var_log_t:dir { getattr search open };
    allow mysqld_t httpd_log_t:dir { getattr search open read lock ioctl };
    allow mysqld_t httpd_log_t:dir { getattr search open };
    allow mysqld_t httpd_log_t:file { open { getattr read ioctl lock } };
    allow mysqld_t httpd_log_t:dir { getattr search open };
    allow mysqld_t httpd_log_t:lnk_file { getattr read };
