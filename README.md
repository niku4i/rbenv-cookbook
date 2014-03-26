rbenv-cookbook
=======================

Chef cookbook for rbenv and ruby-build

Requirements
------------

#### depends
- `yum-epel`

Attributes
----------

#### rbenv::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rbenv']['install_prefix']</tt></td>
    <td>String</td>
    <td>basepath to install rbenv</td>
    <td><tt>/usr/local</tt></td>
  </tr>
  <tr>
    <td><tt>['rbenv']['root_path']</tt></td>
    <td>String</td>
    <td>path to install rbenv</td>
    <td><tt>/usr/local/rbenv</tt></td>
  </tr>
  <tr>
    <td><tt>['rbenv']['rubies']</tt></td>
    <td>Array</td>
    <td>ruby versions to builded by ruby-build.</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['rbenv']['gems']</tt></td>
    <td>Hash</td>
    <td>Install specified gems after building ruby</td>
    <td><tt>{}</tt></td>
  </tr>

</table>

Usage
-----
#### rbenv::default

Include `rbenv` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[rbenv]"
  ],
  "override_attributes": {
    "rbenv": {
      "rubies": [ "2.0.0-p353" ],
      "gems": {
        "2.0.0-p353": [ "bundler" ]
      }
    }
  }
}
```


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
MIT,
Authors: Nobuhiro Nikushi
