##2014-06-27 - Release 1.1.0
### Summary
A bug fix version

#### Features
- Merged pull requests submitted by the user community (THANKS!!!) about dependency issues.

##2014-10-13 - Supported Release 1.0.3
### Summary
Fixed project reference

##2014-10-13 - Supported Release 1.0.2
### Summary
Added logical log parameter to configuration

#### Features
- Added control parameter `keep_logical_logs`.

##2014-10-02 - Supported Release 1.0.1
### Summary
Added changelog and feature for object cache new to version 2.1.5

#### Features
- Added control parameter `cache_memory_ratio` from version 2.1.5 object cache settings.

#### Bugfixes
- Switched to use function `versioncmp` instead.
- Added dependencies and requirements to metadata.

##2014-06-27 - Release 1.0.0
### Summary
The initial release

#### Features
Added custom configuration of:
  1. Version 2.x.x or later
  1. Community or Enterprise editions
  1. JVM Wrapper Settings
  1. File Buffer Cache Options (see Max DeMarzi's blog [Scaling-Up](http://maxdemarzi.com/2013/11/25/scaling-up/))
  1. Object Cache Options
  1. New Relic java agent path specified (see http://www.newrelic.com)
  1. Authentication Plugin installed and configured (see http://www.github.com)
  1. Authenticated User Management
    - Admin User
    - Users and Passwords
    - Read/Write or ReadOnly
  1. High Availability Options
