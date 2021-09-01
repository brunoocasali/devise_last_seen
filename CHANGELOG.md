# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2021-09-01
### Removed
- Remove `activerecord` from gemspec, this gem was added but are not used in the gem context. 

## [0.2.0] - 2021-08-31
### Added
- Add `Devise.last_seen_at_interval` option to allow customization of the interval
- Add `Devise.last_seen_at_attribute` option to allow customization of the attribute name

## [0.1.0] - 2021-08-31
### Added
- Basic feature that updates a pre-existent timestamp column after warden set_user. 
- Add validation to not save a user in invalid state.
- Add integration tests
- Created the changelog file
