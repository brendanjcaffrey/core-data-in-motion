# Core Data in Motion

A light-weight wrapper for Core Data that tries its hardest to be like ActiveRecord.

## Features

### Defining models
```ruby
class Device < CDIM::Model
  # options can be :required => true/false (defaults to false) and/or :default => ...
  property :name, :string, :required => true
  property :ios_version, :float, :default => 6.0, :required => true
  property :udid, :string

  # an enum takes an additional option, an array of possible values
  # it can take a default as well, :default => :mac
  property :type, :enum, :values => [:iphone, :ipad, :mac], :required => true # transparently stored as an :int16
end
```

### Creating records
```ruby
iphone = Device.create(:name => 'iPhone', :type => :iphone, :udid => '...')
# or
ipad = Device.new
ipad.name = 'iPad'
ipad.type = :ipad
ipad.ios_version = 6.1
ipad.save
```

### Updating records
```ruby
iphone.update_attributes(:ios_version => 6.1)
# or
ipad.name = "Brendan's" + ipad.name
ipad.save
```

### Finding records
```ruby
devices = Device.all # more coming soon
```

### Destroying records
```ruby
ipad.destroy
```

### Has-one relationship
```ruby
class Device
  has_one :owner
end

class Owner
  belongs_to :device
end

device = Device.create(:owner => Owner.new(:name => 'test'))
device.owner.name # 'test'

# assignment saves the object being assigned if the parent isn't a new record, but it doesn't save the association between the two
device.owner = nil
device.owner = Owner.new
Device.all.first.owner # still the old object

# create owner saves the association
device.create_owner(:name => 'new owner')

# build saves the parent object to have a nil relation
device.build_owner(:name => 'unsaved')
Device.all.first.owner # nil
device.save
Device.all.first.owner.name # 'unsaved'
```

### Belongs-to relationship
Exactly the same as a has_one, but has_one/has_many relationships won't function without the presence of an inverse belongs_to relationship.

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

## Installation
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

## To-Do

- [x] Model.create
- [x] Model.update_attributes
- [x] Model.all
- [x] Model.save
- [x] Model.destroy/delete
- [x] one-to-one relationships (has one, belongs to)
- [ ] one-to-many relationships (has_many)
- [ ] DSL for filtering and sorting (Model.where(...).limit(1), etc)
- [ ] apply DSL to has_many collections (model.children.where(..))
- [ ] schema migrations

## Thanks to:

- http://swlkr.com/2013/01/02/an-intro-to-core-data-with-ruby-motion/
- http://github.com/alloy/MotionData/
- https://github.com/clearsightstudio/ProMotion (who I stole the Installation instructions from)

