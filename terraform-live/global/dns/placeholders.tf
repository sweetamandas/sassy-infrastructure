# This file contains info for domains that we hold, but just redirect to our
# main page

module "16candies_com" {
  source = "./modules/placeholder-domain"

  name        = "16candies.com"
  dkim_record = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD1piCS7ShHZcbsbGqfMLgmJ4lZNvbjDWvEMMxVNmI+z6ZGT5/ZnT72hRD2ie73mlLOIpBt8uHouWsM8R5uWav4Ts27n4i53sFGx+ctiv8MTA6T6xzMQ1G3uNPwxCRGf1bmZ1xtZjO2uN8LI0midG7us9ZM7Z8HeIVe+w1uf4KgywIDAQAB"
}

module "sweetamanda_com" {
  source = "./modules/placeholder-domain"

  name        = "sweetamanda.com"
  dkim_record = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCcGhp+mrorx19ZM1h16QipoVKoH2nQEXTKgehZzDmvaUhIi/C0q8XnZ8ZS05zbXgcVNPoPZYohCfujGSHxH0bsObOfKIVdBDvCJwJgvFPQTM0q9Etcx74FW4Aah4GfzE5M51nJE7CE1dZ1W+/dwJiow0JOc0672pwds6tLamPU8wIDAQAB"
}

module "sweetamandas_net" {
  source = "./modules/placeholder-domain"

  name = "sweetamandas.net"
}

module "sweetamandas_biz" {
  source = "./modules/placeholder-domain"

  name = "sweetamandas.biz"
}

module "sweetamandas_info" {
  source = "./modules/placeholder-domain"

  name = "sweetamandas.info"
}

module "sweetamandas_org" {
  source = "./modules/placeholder-domain"

  name = "sweetamandas.org"
}

module "amandasanimals_com" {
  source = "./modules/placeholder-domain"

  name = "amandasanimals.com"
}

module "sweetamandascandy_com" {
  source = "./modules/placeholder-domain"

  name        = "sweetamandascandy.com"
  dkim_record = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXfiHg1Ypg+0d02E5B0LF8U9GdTx8U3zVeQEestXfMHXrDjFrsEqUi4SUiptZigUG0cLl2+cUzfEQmjOqMNskYhrY3Wtst5CLDm/z0WeCPX/3JhaptY43/vA8cmma7FmEZ8KBTl587KL2H6TjnGlG6alBJCShla+yu+AYUsF5VtwIDAQAB"
}
