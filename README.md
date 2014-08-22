# Redmine2 Cookbook

[![Build Status](https://secure.travis-ci.org/aminin/redmine2-cookbook.png?branch=master)](http://travis-ci.org/aminin/redmine2-cookbook)

Installs Redmine v2, a Ruby on Rails ticket tracking and wiki tool

## Requirements

### Platform

Tested on ubuntu 12.04

### cookbooks

* postgresql
* [rbenv](https://github.com/fnichol/chef-rbenv)
* [ruby_build](https://github.com/fnichol/chef-ruby_build)
* nginx
* runit
* database

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['redmine2']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
  
  </tr>
  <tr>
    <td><tt>['redmine']['home']</tt></td>
    <td>String</td>
    <td>Location for Redmine application</td>
    <td><tt>/home/redmine</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['host']</tt></td>
    <td>String</td>
    <td>Redmine Domain</td>
    <td><tt>redmine.example.com</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['user']</tt></td>
    <td>String</td>
    <td>Owner of redmine files</td>
    <td><tt>redmine</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['ruby_version']</tt></td>
    <td>String</td>
    <td>Redmine Ruby Version</td>
    <td><tt>1.9.3-p484</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['version']</tt></td>
    <td>String</td>
    <td>Redmine version</td>
    <td><tt>2.4.3</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['db']['type']</tt></td>
    <td>String</td>
    <td>Type of redmine database</td>
    <td><tt>postgresql</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['db']['dbname']</tt></td>
    <td>String</td>
    <td>Redmine DB name</td>
    <td><tt>redmine</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['db']['username']</tt></td>
    <td>String</td>
    <td>Redmine DB user</td>
    <td><tt>redmine</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['db']['hostname']</tt></td>
    <td>String</td>
    <td>Redmine DB host</td>
    <td><tt>localhost</tt></td>
  </tr>
  <tr>
    <td><tt>['redmine']['db']['password']</tt></td>
    <td>String</td>
    <td>Redmine DB password</td>
    <td><tt>123456</tt></td>
  </tr>
</table>

## Usage

To install via librarian-chef add to your Cheffile the following lines

```
cookbook 'rbenv', git: 'https://github.com/fnichol/chef-rbenv'
cookbook 'redmine2', git: 'https://github.com/aminin/redmine2-cookbook'
```

and run `librarian-chef install`

Configure your role/node e.g.:

```json
{
    redmine: {
        host: 'redmine.dev',
        db: {
            password: '<top-secret1>'
        }
    },
    postgresql: {
        password: {
            postgres: '<top-secret2>' # Need admin access to create redmine DB
        }
    },
    run_list: %w(recipe[postgresql::server] recipe[redmine2])
}
```

## Runing tests

```
bundle exec rake foodcritic
bundle exec rake kitchen:all
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: TODO: List authors
