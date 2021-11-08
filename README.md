# Vagrantfile for Magento2

Clone this repository to your local machine.

Copy or rename `config.yaml.sample` to `config.yaml` and configure it as you need:
```bash
$ cp config.yaml.sample config.yaml
$ nano config.yaml
```

<details>
<summary><strong>For Mac users</strong></summary>

If you're Mac user please consider to use mutagen for project synchronization.

If you don't have Magento 2 installed at `./src` then use `mutagen.yaml.sample` sample config, otherwise `mutagen.yml.sample-m2-installed`.

Copy or rename sample mutagen config to `mutagen.yml` and adjust it to your needs.
```bash
$ cp mutagen.yml.sample mutagen.yml
$ nano mutagen.yaml
```
Set the `folders -> magento -> use_mutagen` section inside the `config.yaml` as `true`.
```bash
$ vagrant halt && vagrant up
```

Be sure you have the `~/.ssh/config` file with correct permissions.

---

</details>

Create an empty `src` directory:
```bash
$ mkdir src
```

Run the following command to create and run the virtual machine:
```bash
$ vagrant up
```

After provision please reboot the machine using following commands:
```bash
$ vagrant halt && vagrant up
```

[Install Magento 2](https://devdocs.magento.com/guides/v2.4/install-gde/composer.html#get-the-metapackage) or clone your repository to `src` directory, import database and restart nginx.
