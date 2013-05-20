# Core Data in Motion

A light-weight wrapper for Core Data.

### Features

```ruby
class Device < CDIM::ManagedObject
  # options can be :required => true/false (defaults to false) and/or :default => ...
  property :name, :string, :required => true
  property :ios_version, :float, :default => 6.0, :required => true
  property :udid, :string

  # an enum takes an addition option, an array of possible values
  # it can take a default as well, :default => :mac
  property :type, :enum, :values => [:iphone, :ipad, :mac], :required => true # transparently stored as an :int16
end

Device.create!(:name => 'iPhone', :type => :iphone, :udid => '...')
Device.create!(:name => 'iPad', :type => :ipad, :ios_version => 6.1)

all = Device.all
iphone = all.first
ipad = all.last

iphone.update!(:ios_version => 6.1)
```

### Data Types

* :int16/:integer16
* :int32/:integer32
* :int64/:integer64
* :double
* :float
* :string
* :bool/:boolean
* :binary
* :enum (pass in an array of values - this is not built in to Core Data)

### Installation
Create a new RubyMotion project.

`motion create myapp`

Open it in your favorite editor, then go into your Rakefile and modify the top to look like the following:

```ruby
# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require
```

Create a Gemfile and add the following lines:

```ruby
source 'https://rubygems.org'
gem 'core-data-in-motion', :git => 'git://github.com/brendanjcaffrey/core-data-in-motion.git'
```

Run `bundle install` in Terminal to install Core Data In Motion.

### To-Do

- [x] ManagedObject.create!
- [x] ManagedObject.update!
- [x] ManagedObject.all!
- [ ] ManagedObject.delete!
- [ ] relations (has many, has one, belongs to)
- [ ] DSL for filtering and sorting (Model.where(...).limit(1), etc)
- [ ] schema migrations

### Thanks to:

- Sean Walker for this blog post: http://swlkr.com/2013/01/02/an-intro-to-core-data-with-ruby-motion/
- http://github.com/alloy/MotionData/
- https://github.com/awdogsgo2heaven/superbox
- https://github.com/clearsightstudio/ProMotion (who I stole the Installation instructions from)
