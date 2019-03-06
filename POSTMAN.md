# Postman Integration

The API Commandline Tool (ACT) exports all its commands into [postman-collection.json](postman-collection.json), which is consumable by [postman](https://www.getpostman.com/). Additionally, your environments can be exported into a format consumable by postman with `act.sh environment export <name>`. The following guide summaries the steps you need to take to get the API calls accessible within postman.

## Prerequisites

Before you can get started, you need to install postman. You will find the right version for your operation system at [https://www.getpostman.com/downloads/](https://www.getpostman.com/downloads/).

## Import Requests Collection

On the main screen of postman you will find an **Import** button on the top left corner. Click on it and navigate to **Import from Link** and insert the following URL into the text box:

```
https://raw.githubusercontent.com/Appdynamics/api-commandline-tool/master/postman-collection.json
```

You will immediately see a new folder on the left called "AppDynamics API" with 60+ requests. If you open up that folder, you will see that the categories used by ACT are the names of the subfolders (e.g. application, dbmon, ...). If you open one of the commands you will see that the URL holds a variable called `{{controller_host}}` and that authorisation requires a `{{controller_user}}`, a `{{controller_account}}` and a `{{controller_password}}`. You can set those properties manually or you just can import one of your environments.

## Import an environment

To use ACT, you need to run `act config` or `act environment add` to configure a controller host and credentials. Those details are stored by act and you can export them into a format consumable by postman using `act.sh environment export <name>`:

```json
{
  	"name": "<name>",
  	"values": [
  		{
  			"key": "controller_host",
  			"value": "http://<controllerurl>",
  			"description": "",
  			"enabled": true
  		},
  		{
  			"key": "controller_user",
  			"value": "<user>",
  			"description": "",
  			"enabled": true
  		},
      {
  			"key": "controller_account",
  			"value": "<account>",
  			"description": "",
  			"enabled": true
  		},
      {
  			"key": "controller_password",
  			"value": "<password>",
  			"description": "",
  			"enabled": true
  		}
  	],
  	"_postman_variable_scope": "environment"
  }
```

Copy the output of this command to your clipboard (on a mac you can run `./act.sh environment export demo2`) and go back to postman. Once again, click on **Import** and there open **Paste Raw Text**. Paste the content of your clipboard into the text area and click on **Import**. Immediately, you will see the name of your environment in the top right corner, where postman manages environments. Choose your imported environment before you run any commands.

## Login & Send requests

Some of the requests can be executed using Basic HTTP Authentication, so you can just open them up and click on **Send**. But many of the available commands are protected with a CSRF token. To obtain, this token run the command *AppDynamics API > controller > Authenticate.* The token will be stored as a variable automatically and from now on you are able to run any of the other commands.

## Commands with parameters

Many requests require you to provide a parameter like an application id or a json payload. Those parameters are exported as variables (e.g. `{{application}}` or `{{dashboard_id}}`), so you can configure them as environment variables or global variables to have them reusable. Otherwise, you can replace the variables with the required value.

## Export into Code

Postman comes with the capability to [export an existing request into a code snippet](https://learning.getpostman.com/docs/postman/sending_api_requests/generate_code_snippets/) in different languages (C, C#, Go, Java, JavaScript, Objective-C, OCAML, PHP, Python, Ruby, ...). This means, if you need any of the requests provided in a programming language, you can use those snippets as a template.
