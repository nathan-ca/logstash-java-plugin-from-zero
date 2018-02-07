# logstash-java-plugin-from-zero
A sample logstash plugin for Java developer with zero experience of jruby and plugin development

# Requirement
Experienced Java developer and zero knowledge of logstash, jruby, and logstash java plugin development.

# About This Project
Included in this project are instruction and sample codes used to setup logstash plugin development environment. We'll
develop a simple logstash plugin in 20 minutes. After this project, you still know almost nothing about jruby, but you
can work on logstash plugin development.

# Setup
1 We'll use logstash 5.6.5 as demo release. You can download it from here:
https://www.elastic.co/downloads/past-releases/logstash-5-6-5

Unzip it under ~/demo directory. If you unzip it to another directory, modify setup-logstash.sh file accordingly.
Open a terminal and run '. setup-logstash.sh'. I'll refer this terminal as 'logstash terminal'.

Now run this command:
```
$ ~/demo/logstash-5.6.5/vendor/jruby/bin/jruby -v
jruby 1.7.27 (1.9.3p551) ......
```

What we are doing is find out the jruby version bundled inside logstash. In this release, it's using jruby 1.7.27.

2  Now we go to jruby web site to download the matching jruby release.

http://jruby.org/files/downloads/1.7.27/index.html

We download and unzip jruby under ~/demo directory. If you unzip it to another directory, modify setup-jruby.sh file accordingly.
Open a new terminal and run '. setup-jruby.sh'. I'll refer this terminal as 'jruby terminal'.

Why we need two terminals? During logstash plugin development, jruby will download some extra package and save it to its
lib directory. You will use jruby release (in jruby terminal) to develop and package the plugin. Then in logstash terminal
you install the plugin to test and use it. The jruby under logstash home (/vendor/jruby) will remain as your plugin's end
user environment.

# Play on Logstash
Probably at this time you should read some intro about logstash, let's run a simple config, which I supplied in logstash-conf foloder,
to see if your logstash works.

In your logstash terminal, run this command:

```
$ logstash -f logstash-conf/stdin-stdout.conf
```
If everything works, Logstash just simply echo your input to stdout. Use Ctrl-C to stop logstash.

# Generate Codec Plguin Skeleton and Compile It
In logstash terminal, run this command:
```
$ logstash-plugin generate --type codec --name sample-codec --path ~/demo
```

A new folder logstash-codec-sample-codec will be created with plugin skeleton code. Using this skeleton code, let's
learn a little bit about jruby gem development. Remind again: Use your jruby terminal to compile the jruby gem.


```
$ cd ~/demo/logstash-codec-sample-codec/
```

Before modify any file, you may want to keep a snapshot of original code. This step is optional.

```
$ git init .
$ git add *
$ git status .
$ git commit -m 'initial code'
```

Run this command you'll see some error message:

```
$ gem build logstash-codec-sample-codec.gemspec
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
ERROR:  While executing gem ... (Gem::InvalidSpecificationException)
    "FIXME" or "TODO" is not a description
```

This is the first change you need to do: remove 'FIXME' or 'TODO' in the logstash-codec-sample-codec.gemspec file.
After fix the logstash-codec-sample-codec.gemspec file, you should be able to compile the gem file. Just ignore the
warning messages.

```
$ gem build logstash-codec-sample-codec.gemspec
WARNING:  no author specified
WARNING:  no email specified
WARNING:  no homepage specified
WARNING:  open-ended dependency on logstash-codec-line (>= 0) is not recommended
  if logstash-codec-line is semantically versioned, use:
    add_runtime_dependency 'logstash-codec-line', '~> 0'
WARNING:  open-ended dependency on logstash-devutils (>= 0, development) is not recommended
  if logstash-devutils is semantically versioned, use:
    add_development_dependency 'logstash-devutils', '~> 0'
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: logstash-codec-sample-codec
  Version: 0.1.0
  File: logstash-codec-sample-codec-0.1.0.gem
```

# Test Run the Plugin

Now you should install the plugin, run the command in your logstash terminal to install the plugin:

```
$ logstash-plugin install ~/demo/logstash-codec-sample-codec/logstash-codec-sample-codec-0.1.0.gem
Validating /home/user/demo/logstash-codec-sample-codec/logstash-codec-sample-codec-0.1.0.gem
Installing logstash-codec-sample-codec
Installation successful
```

After install the plugin, try to run it. This time we use the conf file codec-stdout.conf

```
$ logstash -f logstash-conf/codec-stdout.conf
......
[2018-01-11T13:53:36,198][ERROR][logstash.agent           ] Cannot create pipeline {:reason=>"uninitialized constant LogStash::Codecs::Line"}
```

What's wrong? There is an error in the logstash skeleton file. Under logstash-codec-sample-codec directory, modify  logstash/codecs/sample-codec/sample-codec.rb file. Add line:
```
require "logstash/codecs/line"
```
after
```
require "logstash/namespace"
```

Repeat above steps again: compile the gem file in your jruby terminal, then in your logstash terminal, install the plugin and run logstash. This time logstash should run successfully. Your every input will be appended with ', Hello World!' before writing to stdout.

# Learn the Minimal

Now you have a working plugin and practiced how to build and install logstash plugin, you should spend some time take a
look at the directory structure of logstash-codec-sample-codec. The logstash-codec-sample-codec-v1 directory under this
github project folder should have the same code as your logstash-codec-sample-codec folder.

Read the code file: logstash/codecs/sample-codec/sample-codec.rb

The config_name defined in the rb file is the name of your codec, which will be referred in the logstash conf file.

# Develop Your Own Plugin

Now it's time for you to write your own plugin using Java. I have a sample program under java-plugin. The code Processor.java
is simple. Use maven to compile and package it.

# Use Your Plugin

1. Copy two jar files: the codec-1.0.0.jar and gson-2.8.2.jar to plugin development logstash/codecs/sample-codec directory.
Modify sample-codec.rb:

```
4a5
> Dir["#{File.expand_path('..', __FILE__)}/*.jar"].each { |jar| require(jar) }
36c37,39
<       replace = { "message" => line.get("message").to_s + @append }
---
>       @out = Java::codec::Processor.parseInput(line.get("message").to_s)
>       # replace = { "message" => line.get("message").to_s + @append }
>       replace = { "message" => @out }
```

The logstash-codec-sample-codec-v2 directory under this github project folder has the code for your reference. Now compile the
plugin and install it. Logstash will process your input with the logic defined in the Processor.java file. Check it out.

# Work with input plugin
The version 2 code will work with stdin input plugin, but it won't work with some other plugins, e.g., file plugin. To make it work with file input plugin, you should handle the decode method directly. Check the version 3 sample code (sample-codec.rb file) and the sample config file (logstach-conf/file-codec-stdout.conf).

# Conculsion

Processor.java code is simple, it take each line of input (passed in from logstash) and process, convert it based on your
business Requirement. Then the plugin pipeline accept the output of your Process work and continue process it in logstash
pipeline. We have a working structure to develop logstash plugin. The major work will still focus on Java code, only use jruby as
a bridge between Java code and logstash.
