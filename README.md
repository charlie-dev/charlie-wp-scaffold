# Charlie WP Scaffolding

## Configuration within theme.

If your theme does not use composer, you will need to `composer init` within your active theme.

Once you have a `composer.json` file generated, add the following snippet to your `composer.json` file. This will
instruct composer to run scripts in this codebase in the proper order.

```
"scripts": {
    "post-install-cmd": [
      "php -r \"shell_exec('cp -rf vendor/charlie/wp-scaffolder/scripts/. scripts/');\"",
      "php -r \"copy('vendor/charlie/wp-scaffolder/.env', '/');\"",
      "bash scripts/set-env.sh",
      "bash scripts/plugin-extraction.sh",
      "bash scripts/database.sh"
    ],
    "post-update-cmd": [
      "php -r \"shell_exec('cp -rf vendor/charlie/wp-scaffolder/scripts/. scripts/');\"",
      "php -r \"copy('vendor/charlie/wp-scaffolder/.env', '/');\"",
      "bash scripts/set-env.sh",
      "bash scripts/plugin-extraction.sh",
      "bash scripts/database.sh"
    ]
  },
```

Then run `composer install`, this should create a `/scripts` folder within your theme, and if there is no .env present, you will be prompted for your theme name and install path.