#==============================================================================#
#                                Plugin Manager                                #
#                                   by Marin                                   #
#               Support for external plugin scripts by Luka S.J.               #
#                              Tweaked by Maruno                               #
#------------------------------------------------------------------------------#
#   Provides a simple interface that allows plugins to require dependencies    #
#   at specific versions, and to specify incompatibilities between plugins.    #
#                                                                              #
#    Supports external scripts that are in .rb files in folders within the     #
#                               Plugins folder.                                #
#------------------------------------------------------------------------------#
#                                   Usage:                                     #
#                                                                              #
# Each plugin should have its own folder in the "Plugins" folder found in the  #
# main directory. The "Plugins" folder is similar in concept to the "PBS"      #
# folder, in that its contents are compiled and recorded as existing. The      #
# plugin's script file(s) are placed in its folder - they must be .rb files.   #
#                                                                              #
# A plugin's folder must also contain a "meta.txt" file. This file is what     #
# makes Essentials recognise that the plugin exists, and contains important    #
# information about the plugin; if this file does not exist, the folder's      #
# contents are ignored. Each line in this file is a property.                  #
#                                                                              #
# Required lines:                                                              #
#                                                                              #
#     Name       = Simple Extension                          The plugin's name #
#     Version    = 1.0                                    The plugin's version #
#     Essentials = 19.1,20                 Compatible version(s) of Essentials #
#     Link       = https://reliccastle.com/link-to-the-plugin/                 #
#     Credits    = Luka S.J.,Maruno,Marin                    One or more names #
#                                                                              #
# A plugin's version should be in the format X or X.Y or X.Y.Z, where X/Y/Z    #
# are numbers. You can also use Xa, Xb, Xc, Ya, etc. What matters is that you  #
# use version numbers consistently for your plugin. A later version will be    #
# alphanumerically higher than an older version.                               #
#                                                                              #
# Plugins can interact with each other in several ways, such as requiring      #
# another one to exist or by clashing with each other. These interactions are  #
# known as dependencies and conflicts. The lines below are all optional, and   #
# go in "meta.txt" to define how your plugin works (or doesn't work) with      #
# others. You can have multiples of each of these lines.                       #
#                                                                              #
#     Requires   = Basic Plugin            Must have this plugin (any version) #
#     Requires   = Useful Utils,1.1         Must have this plugin/min. version #
#     Exact      = Scene Tweaks,2                Must have this plugin/version #
#     Optional   = Extended Windows,1.2   If this plugin exists, load it first #
#     Conflicts  = Complex Extension                       Incompatible plugin #
#                                                                              #
# A plugin that depends on another one ("Requires"/"Exact"/"Optional") will    #
# make that other plugin be loaded first. The "Optional" line is for a plugin  #
# which isn't necessary, but if it does exist in the same project, it must be  #
# at the given version or higher.                                              #
#                                                                              #
# When plugins are compiled, their scripts are stored in the file              #
# "PluginScripts.rxdata" in the "Data" folder. Dependencies defined above will #
# ensure that they are loaded in a suitable order. Scripts within a plugin are #
# loaded alphanumerically, going through subfolders depth-first.               #
#                                                                              #
# The "Plugins" folder should be deleted when the game is released. Scripts in #
# there are compiled, but any other files used by a plugin (graphics/audio)    #
# should go into other folders and not the plugin's folder.                    #
#                                                                              #
#------------------------------------------------------------------------------#
#                           The code behind plugins:                           #
#                                                                              #
# When a plugin's "meta.txt" file is read, its contents are registered in the  #
# PluginManager. A simple example of registering a plugin is as follows:       #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name       => "Basic Plugin",                                         #
#       :version    => "1.0",                                                  #
#       :essentials => "20",                                                   #
#       :link       => "https://reliccastle.com/link-to-the-plugin/",          #
#       :credits    => ["Marin"]                                               #
#     })                                                                       #
#                                                                              #
# The :link value is optional, but recommended. This will be shown in the      #
# message if the PluginManager detects that this plugin needs to be updated.   #
#                                                                              #
# Here is the same example but also with dependencies and conflicts:           #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name       => "Basic Plugin",                                         #
#       :version    => "1.0",                                                  #
#       :essentials => "20",                                                   #
#       :link       => "https://reliccastle.com/link-to-the-plugin/",          #
#       :credits    => ["Marin"],                                              #
#       :dependencies => ["Basic Plugin",                                      #
#                         ["Useful Utils", "1.1"],                             #
#                         [:exact, "Scene Tweaks", "2"],                       #
#                         [:optional, "Extended Windows", "1.2"],              #
#                        ],                                                    #
#       :incompatibilities => ["Simple Extension"]                             #
#     })                                                                       #
#                                                                              #
# The example dependencies/conflict are the same as the examples shown above   #
# for lines in "meta.txt". :optional_exact is a combination of :exact and      #
# :optional, and there is no way to make use of its combined functionality via #
# "meta.txt".                                                                  #
#                                                                              #
#------------------------------------------------------------------------------#
#                     Please give credit when using this.                      #
#==============================================================================#

module PluginManager
  # Holds all registered plugin data.
  @@Plugins = {}

  # Registers a plugin and tests its dependencies and incompatibilities.
  def self.register(options)
    name         = nil
    version      = nil
    essentials   = nil
    link         = nil
    dependencies = nil
    incompats    = nil
    credits      = []
    order = [:name, :version, :essentials, :link, :dependencies, :incompatibilities, :credits]
    # Ensure it first reads the plugin's name, which is used in error reporting,
    # by sorting the keys
    keys = options.keys.sort do |a, b|
      idx_a = order.index(a) || order.size
      idx_b = order.index(b) || order.size
      next idx_a <=> idx_b
    end
    keys.each do |key|
      value = options[key]
      case key
      when :name   # Plugin name
        if nil_or_empty?(value)
          self.error("Plugin name must be a non-empty string.")
        end
        if !@@Plugins[value].nil?
          self.error("A plugin called '#{value}' already exists.")
        end
        name = value
      when :version   # Plugin version
        self.error("Plugin version must be a string.") if nil_or_empty?(value)
        version = value
      when :essentials
        essentials = value
      when :link   # Plugin website
        if nil_or_empty?(value)
          self.error("Plugin link must be a non-empty string.")
        end
        link = value
      when :dependencies   # Plugin dependencies
        dependencies = value
        dependencies = [dependencies] if !dependencies.is_a?(Array) || !dependencies[0].is_a?(Array)
        value.each do |dep|
          case dep
          when String   # "plugin name"
            if !self.installed?(dep)
              self.error("Plugin '#{name}' requires plugin '#{dep}' to be installed above it.")
            end
          when Array
            case dep.size
            when 1   # ["plugin name"]
              if dep[0].is_a?(String)
                dep_name = dep[0]
                if !self.installed?(dep_name)
                  self.error("Plugin '#{name}' requires plugin '#{dep_name}' to be installed above it.")
                end
              else
                self.error("Expected the plugin name as a string, but got #{dep[0].inspect}.")
              end
            when 2   # ["plugin name", "version"]
              if dep[0].is_a?(Symbol)
                self.error("A plugin version comparator symbol was given but no version was given.")
              elsif dep[0].is_a?(String) && dep[1].is_a?(String)
                dep_name    = dep[0]
                dep_version = dep[1]
                next if self.installed?(dep_name, dep_version)
                if self.installed?(dep_name)   # Have plugin but lower version
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}' version #{dep_version} or higher, " +
                        "but the installed version is #{self.version(dep_name)}."
                  dep_link = self.link(dep_name)
                  if dep_link
                    msg += "\r\nCheck #{dep_link} for an update to plugin '#{dep_name}'."
                  end
                  self.error(msg)
                else   # Don't have plugin
                  self.error("Plugin '#{name}' requires plugin '#{dep_name}' version #{dep_version} " +
                      "or higher to be installed above it.")
                end
              end
            when 3   # [:optional/:exact/:optional_exact, "plugin name", "version"]
              if !dep[0].is_a?(Symbol)
                self.error("Expected first dependency argument to be a symbol, but got #{dep[0].inspect}.")
              end
              if !dep[1].is_a?(String)
                self.error("Expected second dependency argument to be a plugin name, but got #{dep[1].inspect}.")
              end
              if !dep[2].is_a?(String)
                self.error("Expected third dependency argument to be the plugin version, but got #{dep[2].inspect}.")
              end
              dep_arg     = dep[0]
              dep_name    = dep[1]
              dep_version = dep[2]
              optional    = false
              exact       = false
              case dep_arg
              when :optional
                optional = true
              when :exact
                exact = true
              when :optional_exact
                optional = true
                exact = true
              else
                self.error("Expected first dependency argument to be one of " +
                           ":optional, :exact or :optional_exact, but got #{dep_arg.inspect}.")
              end
              if optional
                if self.installed?(dep_name) &&   # Have plugin but lower version
                   !self.installed?(dep_name, dep_version, exact)
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}', if installed, to be version #{dep_version}"
                  msg << " or higher" if !exact
                  msg << ", but the installed version was #{self.version(dep_name)}."
                  dep_link = self.link(dep_name)
                  if dep_link
                    msg << "\r\nCheck #{dep_link} for an update to plugin '#{dep_name}'."
                  end
                  self.error(msg)
                end
              elsif !self.installed?(dep_name, dep_version, exact)
                if self.installed?(dep_name)   # Have plugin but lower version
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}' to be version #{dep_version}"
                  msg << " or later" if !exact
                  msg << ", but the installed version was #{self.version(dep_name)}."
                  dep_link = self.link(dep_name)
                  if dep_link
                    msg << "\r\nCheck #{dep_link} for an update to plugin '#{dep_name}'."
                  end
                else   # Don't have plugin
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}' version #{dep_version} "
                  msg << "or later " if !exact
                  msg << "to be installed above it."
                end
                self.error(msg)
              end
            end
          end
        end
      when :incompatibilities   # Plugin incompatibilities
        incompats = value
        incompats = [incompats] if !incompats.is_a?(Array)
        incompats.each do |incompat|
          if self.installed?(incompat)
            self.error("Plugin '#{name}' is incompatible with '#{incompat}'. They cannot both be used at the same time.")
          end
        end
      when :credits # Plugin credits
        value = [value] if value.is_a?(String)
        if value.is_a?(Array)
          value.each do |entry|
            if entry.is_a?(String)
              credits << entry
            else
              self.error("Plugin '#{name}'s credits array contains a non-string value.")
            end
          end
        else
          self.error("Plugin '#{name}'s credits field must contain a string, or a string array.")
        end
      else
        self.error("Invalid plugin registry key '#{key}'.")
      end
    end
    @@Plugins.each_value do |plugin|
      if plugin[:incompatibilities]&.include?(name)
        self.error("Plugin '#{plugin[:name]}' is incompatible with '#{name}'. They cannot both be used at the same time.")
      end
    end
    # Add plugin to class variable
    @@Plugins[name] = {
      :name              => name,
      :version           => version,
      :essentials        => essentials,
      :link              => link,
      :dependencies      => dependencies,
      :incompatibilities => incompats,
      :credits           => credits
    }
  end

  # Throws a pure error message without stack trace or any other useless info.
  def self.error(msg)
    Graphics.update
    t = Thread.new do
      Console.echo_error("Plugin Error:\r\n#{msg}")
      print("Plugin Error:\r\n#{msg}")
      Thread.exit
    end
    while t.status
      Graphics.update
    end
    Kernel.exit! true
  end

  # Returns true if the specified plugin is installed.
  # If the version is specified, this version is taken into account.
  # If mustequal is true, the version must be a match with the specified version.
  def self.installed?(plugin_name, plugin_version = nil, mustequal = false)
    plugin = @@Plugins[plugin_name]
    return false if plugin.nil?
    return true if plugin_version.nil?
    comparison = compare_versions(plugin[:version], plugin_version)
    return true if !mustequal && comparison >= 0
    return true if mustequal && comparison == 0
  end

  # Returns the string names of all installed plugins.
  def self.plugins
    return @@Plugins.keys
  end

  # Returns the installed version of the specified plugin.
  def self.version(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:version]
  end

  # Returns the link of the specified plugin.
  def self.link(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:link]
  end

  # Returns the credits of the specified plugin.
  def self.credits(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:credits]
  end

  # Compares two versions given in string form. v1 should be the plugin version
  # you actually have, and v2 should be the minimum/desired plugin version.
  # Return values:
  #     1 if v1 is higher than v2
  #     0 if v1 is equal to v2
  #     -1 if v1 is lower than v2
  def self.compare_versions(v1, v2)
    d1 = v1.chars
    d1.insert(0, "0") if d1[0] == "."   # Turn ".123" into "0.123"
    while d1[-1] == "."                 # Turn "123." into "123"
      d1 = d1[0..-2]
    end
    d2 = v2.chars
    d2.insert(0, "0") if d2[0] == "."   # Turn ".123" into "0.123"
    while d2[-1] == "."                 # Turn "123." into "123"
      d2 = d2[0..-2]
    end
    [d1.size, d2.size].max.times do |i|   # Compare each digit in turn
      c1 = d1[i]
      c2 = d2[i]
      if c1
        return 1 if !c2
        return 1 if c1.to_i(16) > c2.to_i(16)
        return -1 if c1.to_i(16) < c2.to_i(16)
      elsif c2
        return -1
      end
    end
    return 0
  end

  # Formats the error message
  def self.pluginErrorMsg(name, script)
    e = $!
    # begin message formatting
    message = "[Pokémon Essentials version #{Essentials::VERSION}]\r\n"
    message += "#{Essentials::ERROR_TEXT}\r\n"   # For third party scripts to add to
    message += "Error in Plugin: [#{name}]\r\n"
    message += "Exception: #{e.class}\r\n"
    message += "Message: "
    message += e.message
    # show last 10 lines of backtrace
    message += "\r\n\r\nBacktrace:\r\n"
    e.backtrace[0, 10].each { |i| message += "#{i}\r\n" }
    # output to log
    errorlog = "errorlog.txt"
    errorlog = RTP.getSaveFileName("errorlog.txt") if (Object.const_defined?(:RTP) rescue false)
    File.open(errorlog, "ab") do |f|
      f.write("\r\n=================\r\n\r\n[#{Time.now}]\r\n")
      f.write(message)
    end
    # format/censor the error log directory
    errorlogline = errorlog.gsub("/", "\\")
    errorlogline.sub!(Dir.pwd + "\\", "")
    errorlogline.sub!(pbGetUserName, "USERNAME")
    errorlogline = "\r\n" + errorlogline if errorlogline.length > 20
    # output message
    print("#{message}\r\nThis exception was logged in #{errorlogline}.\r\nHold Ctrl when closing this message to copy it to the clipboard.")
    # Give a ~500ms coyote time to start holding Control
    t = System.uptime
    until System.uptime - t >= 0.5
      Input.update
      if Input.press?(Input::CTRL)
        Input.clipboard = message
        break
      end
    end
  end

  # Used to read the metadata file
  def self.readMeta(dir, file)
    filename = "#{dir}/#{file}"
    meta = {}
    # read file
    Compiler.pbCompilerEachPreppedLine(filename) do |line, line_no|
      # split line up into property name and values
      if !line[/^\s*(\w+)\s*=\s*(.*)$/]
        raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}", FileLineData.linereport)
      end
      property = $~[1].upcase
      data = $~[2].split(",")
      data.each_with_index { |value, i| data[i] = value.strip }
      # begin formatting data hash
      case property
      when "ESSENTIALS"
        meta[:essentials] = [] if !meta[:essentials]
        data.each { |ver| meta[:essentials].push(ver) }
      when "REQUIRES"
        meta[:dependencies] = [] if !meta[:dependencies]
        if data.length < 2   # No version given, just push name of plugin dependency
          meta[:dependencies].push(data[0])
          next
        elsif data.length == 2   # Push name and version of plugin dependency
          meta[:dependencies].push([data[0], data[1]])
        else   # Push dependency type, name and version of plugin dependency
          meta[:dependencies].push([data[2].downcase.to_sym, data[0], data[1]])
        end
      when "EXACT"
        next if data.length < 2   # Exact dependencies must have a version given; ignore if not
        meta[:dependencies] = [] if !meta[:dependencies]
        meta[:dependencies].push([:exact, data[0], data[1]])
      when "OPTIONAL"
        next if data.length < 2   # Optional dependencies must have a version given; ignore if not
        meta[:dependencies] = [] if !meta[:dependencies]
        meta[:dependencies].push([:optional, data[0], data[1]])
      when "CONFLICTS"
        meta[:incompatibilities] = [] if !meta[:incompatibilities]
        data.each { |value| meta[:incompatibilities].push(value) if value && !value.empty? }
      when "SCRIPTS"
        meta[:scripts] = [] if !meta[:scripts]
        data.each { |scr| meta[:scripts].push(scr) }
      when "CREDITS"
        meta[:credits] = data
      when "LINK", "WEBSITE"
        meta[:link] = data[0]
      else
        meta[property.downcase.to_sym] = data[0]
      end
    end
    # generate a list of all script files to be loaded, in the order they are to
    # be loaded (files listed in the meta file are loaded first)
    meta[:scripts] = [] if !meta[:scripts]
    # get all script files from plugin Dir
    Dir.all(dir).each do |fl|
      next if !fl.include?(".rb")
      meta[:scripts].push(fl.gsub("#{dir}/", ""))
    end
    # ensure no duplicate script files are queued
    meta[:scripts].uniq!
    # return meta hash
    return meta
  end

  # Get a list of all the plugin directories to inspect
  def self.listAll
    return [] if !$DEBUG || FileTest.exist?("Game.rgssad") || !Dir.safe?("Plugins")
    # get a list of all directories in the `Plugins/` folder
    dirs = []
    Dir.get("Plugins").each { |d| dirs.push(d) if Dir.safe?(d) }
    # return all plugins
    return dirs
  end

  # Catch any potential loop with dependencies and raise an error
  def self.validateDependencies(name, meta, og = nil)
    # exit if no registered dependency
    return nil if !meta[name] || !meta[name][:dependencies]
    og = [name] if !og
    # go through all dependencies
    meta[name][:dependencies].each do |dname|
      # clean the name to a simple string
      dname = dname[0] if dname.is_a?(Array) && dname.length == 2
      dname = dname[1] if dname.is_a?(Array) && dname.length == 3
      # catch looping dependency issue
      self.error("Plugin '#{og[0]}' has looping dependencies which cannot be resolved automatically.") if !og.nil? && og.include?(dname)
      new_og = og.clone
      new_og.push(dname)
      self.validateDependencies(dname, meta, new_og)
    end
    return name
  end

  # Sort load order based on dependencies (this ends up in reverse order)
  def self.sortLoadOrder(order, plugins)
    # go through the load order
    order.each do |o|
      next if !plugins[o] || !plugins[o][:dependencies]
      # go through all dependencies
      plugins[o][:dependencies].each do |dname|
        optional = false
        # clean the name to a simple string
        if dname.is_a?(Array)
          optional = [:optional, :optional_exact].include?(dname[0])
          dname = dname[dname.length - 2]
        end
        # catch missing dependency
        if !order.include?(dname)
          next if optional
          self.error("Plugin '#{o}' requires plugin '#{dname}' to work properly.")
        end
        # skip if already sorted
        next if order.index(dname) > order.index(o)
        # catch looping dependency issue
        order.swap(o, dname)
        order = self.sortLoadOrder(order, plugins)
      end
    end
    return order
  end

  # Get the order in which to load plugins
  def self.getPluginOrder
    plugins = {}
    order = []
    # Find all plugin folders that have a meta.txt and add them to the list of
    # plugins.
    self.listAll.each do |dir|
      # skip if there is no meta file
      next if !FileTest.exist?(dir + "/meta.txt")
      ndx = order.length
      meta = self.readMeta(dir, "meta.txt")
      meta[:dir] = dir
      # raise error if no name defined for plugin
      self.error("No 'Name' metadata defined for plugin located at '#{dir}'.") if !meta[:name]
      # raise error if no script defined for plugin
      self.error("No 'Scripts' metadata defined for plugin located at '#{dir}'.") if !meta[:scripts]
      plugins[meta[:name]] = meta
      # raise error if a plugin with the same name already exists
      self.error("A plugin called '#{meta[:name]}' already exists in the load order.") if order.include?(meta[:name])
      order.insert(ndx, meta[:name])
    end
    # validate all dependencies
    order.each { |o| self.validateDependencies(o, plugins) }
    # sort the load order
    return self.sortLoadOrder(order, plugins).reverse, plugins
  end

  # Check if plugins need compiling
  def self.needCompiling?(order, plugins)
    # fixed actions
    return false if !$DEBUG || FileTest.exist?("Game.rgssad")
    return true if !FileTest.exist?("Data/PluginScripts.rxdata")
    Input.update
    return true if Input.press?(Input::SHIFT) || Input.press?(Input::CTRL)
    # analyze whether or not to push recompile
    mtime = File.mtime("Data/PluginScripts.rxdata")
    order.each do |o|
      # go through all the registered plugin scripts
      scr = plugins[o][:scripts]
      dir = plugins[o][:dir]
      scr.each do |sc|
        return true if File.mtime("#{dir}/#{sc}") > mtime
      end
      return true if File.mtime("#{dir}/meta.txt") > mtime
    end
    return false
  end

  # Check if plugins need compiling
  def self.compilePlugins(order, plugins)
    Console.echo_li("Compiling plugin scripts...")
    scripts = []
    # go through the entire order one by one
    order.each do |o|
      # save name, metadata and scripts array
      meta = plugins[o].clone
      meta.delete(:scripts)
      meta.delete(:dir)
      dat = [o, meta, []]
      # iterate through each file to deflate
      plugins[o][:scripts].each do |file|
        File.open("#{plugins[o][:dir]}/#{file}", "rb") do |f|
          dat[2].push([file, Zlib::Deflate.deflate(f.read)])
        end
      end
      # push to the main scripts array
      scripts.push(dat)
    end
    # save to main `PluginScripts.rxdata` file
    File.open("Data/PluginScripts.rxdata", "wb") { |f| Marshal.dump(scripts, f) }
    # collect garbage
    GC.start
    Console.echo_done(true)
  end

  # Check if plugins need compiling
  def self.runPlugins
    Console.echo_h1("Checking plugins")
    # get the order of plugins to interpret
    order, plugins = self.getPluginOrder
    # compile if necessary
    if self.needCompiling?(order, plugins)
      self.compilePlugins(order, plugins)
    else
      Console.echoln_li("Plugins were not compiled")
    end
    # load plugins
    scripts = load_data("Data/PluginScripts.rxdata")
    echoed_plugins = []
    scripts.each do |plugin|
      # get the required data
      name, meta, script = plugin
      if !meta[:essentials] || !meta[:essentials].include?(Essentials::VERSION)
        Console.echo_warn("Plugin '#{name}' may not be compatible with Essentials v#{Essentials::VERSION}. Trying to load anyway.")
      end
      # register plugin
      self.register(meta)
      # go through each script and interpret
      script.each do |scr|
        # turn code into plaintext
        code = Zlib::Inflate.inflate(scr[1]).force_encoding(Encoding::UTF_8)
        # get rid of tabs
        code.gsub!("\t", "  ")
        # construct filename
        sname = scr[0].gsub("\\", "/").split("/")[-1]
        fname = "[#{name}] #{sname}"
        # try to run the code
        begin
          eval(code, TOPLEVEL_BINDING, fname)
          Console.echoln_li("Loaded plugin: ==#{name}== (ver. #{meta[:version]})") if !echoed_plugins.include?(name)
          echoed_plugins.push(name)
        rescue Exception   # format error message to display
          self.pluginErrorMsg(name, sname)
          Kernel.exit! true
        end
      end
    end
    if scripts.length > 0
      Console.echoln_li_done("Successfully loaded #{scripts.length} plugin(s)")
    else
      Console.echoln_li_done("No plugins found")
    end
  end

  # Get plugin dir from name based on meta entries
  def self.findDirectory(name)
    # go through the plugins folder
    Dir.get("Plugins").each do |dir|
      next if !Dir.safe?(dir)
      next if !FileTest.exist?(dir + "/meta.txt")
      # read meta
      meta = self.readMeta(dir, "meta.txt")
      return dir if meta[:name] == name
    end
    # return nil if no plugin dir found
    return nil
  end
end
