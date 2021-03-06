
![travis-ci](http://travis-ci.org/nfedyashev/repository.png)

Description
--------

A Ruby implementation of the Repository Pattern, as described in many OO/Patterns books but notably martinfowler.com/eaaCatalog/repository.html and www.infoq.com/resource/minibooks/domain-driven-design-quickly/en/pdf/DomainDrivenDesignQuicklyOnline.pdf (p.51)

From Fowler/Hieatt/Mee: “A system with a complex domain model often benefits from a layer, such as the one provided by Data Mapper, that isolates domain objects from details of the database access code. In such systems it can be worthwhile to build another layer of abstraction over the mapping layer where query construction code is concentrated. This becomes more important when there are a large number of domain classes or heavy querying. In these cases particularly, adding this layer helps minimize duplicate query logic. A Repository mediates between the domain and data mapping layers, acting like an in-memory domain object collection.”

In Repository, queries are specified using a DSL and turn into Criterion objects, which are then passed to the Repository for matching against the data store.

Examples
--------

``` ruby
class User < OpenStruct
end  

user = User.new(id: 1, name: 'John')
=> #<User id=1, name="John">

user = User.new(id: 2, name: 'Mike')
=> #<User id=2, name="Mike">

Repository[User].store(user)
=> [#<User id=2, name="Mike">]

Repository[User].search(user.id)
=> [#<User id=2, name="Mike">]

def find_by_id_or_name(value)
  c = Repository::Criterion::Or.new(
    (Repository::Criterion::Equals.new(:subject => "id", :value => value)),
    (Repository::Criterion::Equals.new(:subject => "name", :value => value))
  )
  Repository[User].search(c)
end

find_by_id_or_name('Mike')
=> [#<User id=2, name="Mike">]

```

Check out specs for more examples.

Installation
-------

Install the gem:

``` bash
$ gem install repository
```

Add it to your Gemfile:

``` ruby
gem 'repository'
```

Supported Ruby Versions
-------

[travis]: http://travis-ci.org/nfedyashev/repository

This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.2
* Ruby 1.9.3

Submitting a Pull Request
-------

1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add specs for your feature or bug fix.
5. Run `bundle exec rake spec`. If your changes are not 100% covered, go back to step 4.
6. Commit and push your changes.
7. Submit a pull request. Please do not include changes to the gemspec,
   version, or history file. (If you want to create your own version for some
   reason, please do so in a separate commit.)


Credits
-------

That is a simplified version of the https://github.com/alexch/treasury which supports only in-memory database with minimum features and overhead. If you need more features or support of other storage methods you may check out the original repo.


Copyright © 2009 Alex Chaffee
Copyright © 2012 Nikita Fedyashev

See LICENSE.txt for further details.

