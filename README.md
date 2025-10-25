# Plugin **Engel Webhook** 🔌

---

## 📄 Visão Geral

O plugin **Engel Webhook** adiciona funcionalidades de _webhook_ ao seu ambiente Redmine. Ele permite que você envie notificações e dados sobre eventos específicos do Redmine (como criação ou atualização de *issues*) para serviços externos.

---

## 🛠️ Requisitos

Para instalar e utilizar o plugin **Engel Webhook**, certifique-se de que seu ambiente Redmine atenda aos seguintes requisitos:

* **Redmine:** Versão **6.x** ou superior.
* **Ruby:** Versão **7.x** ou superior.

---

## 🚀 Instalação

Siga os passos abaixo para instalar o plugin **Engel Webhook** em sua instância Redmine:

### **1. Clone o Repositório**

Navegue até o diretório raiz da sua instalação Redmine e clone o repositório do plugin para a pasta `plugins`:

```bash
cd $REDMINE_ROOT
git clone [https://github.com/CristianKreuzEngel/engel-hook.git](https://github.com/CristianKreuzEngel/engel-hook.git) plugins/engel_webhook
```
### ***2. Instale as Dependências

É recomendado instalar as dependências do plugin pulando os grupos de development e test para um ambiente de produção mais limpo:
```bash

# Configura a exclusão dos grupos de desenvolvimento e teste
bundle config set --local without 'development test'

# Instala as gems necessárias

bundle install
```
### ***3. Execute as Migrações

Execute o comando de migração para criar as tabelas ou estruturas de dados necessárias no banco de dados do Redmine:
```bash
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```
#### ***4. Reinicie o Redmine

Após a migração, é essencial reiniciar o servidor de aplicação do Redmine (por exemplo, Apache, Unicorn, Puma, etc.) para que o plugin seja carregado corretamente e as alterações entrem em vigor.

⚙️ Configuração (Opcional)

Após a instalação, vá para Administração → Plugins, encontre o Engel Webhook e clique em Configurar. Aqui você poderá:

    Definir a URL para onde será enviado os eventos.

    Selecionar os eventos que devem disparar as notificações (ex: issue adicionada, issue atualizada).

    Configurar chaves de segurança (se aplicável).

🐛 Suporte e Contribuições

Este projeto está aberto a contribuições e sugestões. Se você encontrar algum problema ou quiser propor melhorias, por favor, abra uma issue ou um pull request no repositório do GitHub.