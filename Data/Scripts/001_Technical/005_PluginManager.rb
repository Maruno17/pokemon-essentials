#==============================================================================#
#                                Plugin Manager                                #
#                                   by Marin                                   #
#               support for external plugin scripts by Luka S.J.               #
#                              tweaked by Maruno                               #
#------------------------------------------------------------------------------#
#   Provides a simple interface that allows plugins to require dependencies    #
#   at specific versions, and to specify incompatibilities between plugins.    #
#                                                                              #
#    Supports external scripts that are in .rb files in folders within the     #
#                               Plugins folder.                                #
#------------------------------------------------------------------------------#
#                                   Usage:                                     #
#                                                                              #
# A Pokémon Essentials plugin should register itself using the PluginManager.  #
# The simplest way to do so, for a plugin without dependencies, is as follows: #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Basic Plugin",                                            #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => "Marin"                                                    #
#     })                                                                       #
#                                                                              #
# The link portion here is optional, but recommended. This will be shown in    #
# the error message if the PluginManager detects that this plugin needs to be  #
# updated.                                                                     #
#                                                                              #
# A plugin's version should be in the format X.Y.Z, but the number of digits   #
# you use does not matter. You can also use Xa, Xb, Xc, Ya, etc.               #
# What matters is that you use it consistently, so that it can be compared.    #
#                                                                              #
# IF there are multiple people to credit, their names should be in an array.   #
# If there is only one credit, it does not need an array:                      #
#                                                                              #
#     :credits => "Marin"                                                      #
#     :credits => ["Marin", "Maruno"],                                         #
#                                                                              #
#                                                                              #
#                                                                              #
# Dependency:                                                                  #
#                                                                              #
# A plugin can require another plugin to be installed in order to work. For    #
# example, the "Simple Extension" plugin depends on the above "Basic Plugin"   #
# like so:                                                                     #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Simple Extension",                                        #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => ["Marin", "Maruno"],                                       #
#       :dependencies => ["Basic Plugin"]                                      #
#     })                                                                       #
#                                                                              #
# If there are multiple dependencies, they should be listed in an array. If    #
# there is only one dependency, it does not need an array:                     #
#                                                                              #
#     :dependencies => "Basic Plugin"                                          #
#                                                                              #
# To require a minimum version of a dependency plugin, you should turn the     #
# dependency's name into an array which contains the name and the version      #
# (both as strings). For example, to require "Basic Plugin" version 1.2 or     #
# higher, you would write:                                                     #
#                                                                              #
#     :dependencies => [                                                       #
#       ["Basic Plugin", "1.2"]                                                #
#     ]                                                                        #
#                                                                              #
# To require a specific version (no higher and no lower) of a dependency       #
# plugin, you should add the :exact flag as the first thing in the array for   #
# that dependency:                                                             #
#                                                                              #
#     :dependencies => [                                                       #
#       [:exact, "Basic Plugin", "1.2"]                                        #
#     ]                                                                        #
#                                                                              #
# If your plugin can work without another plugin, but it is incompatible with  #
# an old version of that other plugin, you should list it as an optional       #
# dependency. If that other plugin is present in a game, then this optional    #
# dependency will check whether it meets the minimum version required for your #
# plugin. Write it in the same way as any other dependency as described above, #
# but use the :optional flag instead.                                          #
#                                                                              #
#     :dependencies => [                                                       #
#       [:optional, "QoL Improvements", "1.1"]                                 #
#     ]                                                                        #
#                                                                              #
# The :optional_exact flag is a combination of :optional and :exact.           #
#                                                                              #
#                                                                              #
#                                                                              #
# Incompatibility:                                                             #
#                                                                              #
# If your plugin is known to be incompatible with another plugin, you should   #
# list that other plugin as such. Only one of the two plugins needs to list    #
# that it is incompatible with the other.                                      #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "QoL Improvements",                                        #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => "Marin",                                                   #
#       :incompatibilities => [                                                #
#         "Simple Extension"                                                   #
#       ]                                                                      #
#     })                                                                       #
#                                                                              #
#------------------------------------------------------------------------------#
#                               Plugin folder:                                 #
#                                                                              #
# The Plugin folder is treated like the PBS folder, but for script files for   #
# plugins. Each plugin has its own folder within the Plugin folder. Each       #
# plugin must have a meta.txt file in its folder, which contains information   #
# about that plugin. Folders without this meta.txt file are ignored.           #
#                                                                              #
# Scripts must be in .rb files. You should not put any other files into a      #
# plugin's folder except for script files and meta.txt.                        #
#                                                                              #
# When the game is compiled, scripts in these folders are read and converted   #
# into a usable format, and saved in the file Data/PluginScripts.rxdata.       #
# Script files are loaded in order of their name and subfolder, so it is wise  #
# to name script files "001_first script.rb", "002_second script.rb", etc. to  #
# ensure they are loaded in the correct order.                                 #
#                                                                              #
# When the game is compressed for distribution, the Plugin folder and all its  #
# contents should be deleted (like the PBS folder), because its contents will  #
# be unused (they will have been compiled into the PluginScripts.rxdata file). #
#                                                                              #
# The contents of meta.txt are as follows:                                     #
#                                                                              #
#     Name         = Simple Extension                                          #
#     Version      = 1.0                                                       #
#     Requires     = Basic Plugin                                              #
#     Requires     = Useful Utilities,1.1                                      #
#     Conflicts    = Complex Extension                                         #
#     Conflicts    = Extended Windows                                          #
#     Link         = https://reliccastle.com/link-to-the-plugin/               #
#     Credits      = Luka S.J.,Maruno,Marin                                    #
#                                                                              #
# These lines are related to what is described above. You can have multiple    #
# "Requires" and "Conflicts" lines, each listing a single other plugin that is #
# either a dependency or a conflict respectively.                              #
#                                                                              #
# Examples of the "Requires" line:                                             #
#                                                                              #
#     Requires     = Basic Plugin                                              #
#     Requires     = Basic Plugin,1.1                                          #
#     Requires     = Basic Plugin,1.1,exact                                    #
#     Requires     = Basic Plugin,1.1,optional                                 #
#     Exact        = Basic Plugin,1.1                                          #
#     Optional     = Basic Plugin,1.1                                          #
#                                                                              #
# The "Exact" and "Optional" lines are equivalent to the "Requires" lines      #
# that contain those keywords.                                                 #
#                                                                              #
# There is also a "Scripts" line, which lists one or more script files that    #
# should be loaded first. You can have multiple "Scripts" lines. However, you  #
# can achieve the same effect by simply naming your script files in            #
# alphanumeric order to make them load in a particular order, so the "Scripts" #
# line should not be necessary.                                                #
#                                                                              #
#------------------------------------------------------------------------------#
#                     Please give credit when using this.                      #
#==============================================================================#

module PluginManager
  # Holds all registered plugin data.
  @@Plugins = {}
  #-----------------------------------------------------------------------------
  # Registers a plugin and tests its dependencies and incompatibilities.
  #-----------------------------------------------------------------------------
  def self.register(options)
    name         = nil
    version      = nil
    link         = nil
    dependencies = nil
    incompats    = nil
    credits      = []
    order = [:name, :version, :link, :dependencies, :incompatibilities, :credits]
    # Ensure it first reads the plugin's name, which is used in error reporting,
    # by sorting the keys
    keys = options.keys.sort do |a, b|
      idx_a = order.index(a)
      idx_a = order.size if idx_a == -1
      idx_b = order.index(b)
      idx_b = order.size if idx_b == -1
      next idx_a <=> idx_b
    end
    for key in keys
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
        if nil_or_empty?(value)
          self.error("Plugin version must be a string.")
        end
        version = value
      when :link   # Plugin website
        if nil_or_empty?(value)
          self.error("Plugin link must be a non-empty string.")
        end
        link = value
      when :dependencies   # Plugin dependencies
        dependencies = value
        dependencies = [dependencies] if !dependencies.is_a?(Array) || !dependencies[0].is_a?(Array)
        for dep in value
          if dep.is_a?(String)   # "plugin name"
            if !self.installed?(dep)
              self.error("Plugin '#{name}' requires plugin '#{dep}' to be installed above it.")
            end
          elsif dep.is_a?(Array)
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
                  if dep_link = self.link(dep_name)
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
              case def_arg
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
                  if dep_link = self.link(dep_name)
                    msg << "\r\nCheck #{dep_link} for an update to plugin '#{dep_name}'."
                  end
                  self.error(msg)
                end
              elsif !self.installed?(dep_name, dep_version, exact)
                if self.installed?(dep_name)   # Have plugin but lower version
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}' to be version #{dep_version}"
                  msg << " or later" if !exact
                  msg << ", but the installed version was #{self.version(dep_name)}."
                  if dep_link = self.link(dep_name)
                    msg << "\r\nCheck #{dep_link} for an update to plugin '#{dep_name}'."
                  end
                  self.error(msg)
                else   # Don't have plugin
                  msg = "Plugin '#{name}' requires plugin '#{dep_name}' version #{dep_version} "
                  msg << "or later" if !exact
                  msg << "to be installed above it."
                  self.error(msg)
                end
              end
            end
          end
        end
      when :incompatibilities   # Plugin incompatibilities
        incompats = value
        incompats = [incompats] if !incompats.is_a?(Array)
        for incompat in incompats
          if self.installed?(incompat)
            self.error("Plugin '#{name}' is incompatible with '#{incompat}'. " +
                       "They cannot both be used at the same time.")
          end
        end
      when :credits # Plugin credits
        value = [value] if value.is_a?(String)
        if value.is_a?(Array)
          for entry in value
            if !entry.is_a?(String)
              self.error("Plugin '#{name}'s credits array contains a non-string value.")
            else
              credits << entry
            end
          end
        else
          self.error("Plugin '#{name}'s credits field must contain a string, or a string array.")
        end
      else
        self.error("Invalid plugin registry key '#{key}'.")
      end
    end
    for plugin in @@Plugins.values
      if plugin[:incompatibilities] && plugin[:incompatibilities].include?(name)
        self.error("Plugin '#{plugin[:name]}' is incompatible with '#{name}'. " +
                   "They cannot both be used at the same time.")
      end
    end
    # Add plugin to class variable
    @@Plugins[name] = {
      :name => name,
      :version => version,
      :link => link,
      :dependencies => dependencies,
      :incompatibilities => incompats,
      :credits => credits
    }
  end
  #-----------------------------------------------------------------------------
  # Throws a pure error message without stack trace or any other useless info.
  #-----------------------------------------------------------------------------
  def self.error(msg)
    Graphics.update
    t = Thread.new do
      echoln "Plugin Error:\r\n#{msg}"
      p "Plugin Error: #{msg}"
      Thread.exit
    end
    while t.status
      Graphics.update
    end
    Kernel.exit! true
  end
  #-----------------------------------------------------------------------------
  # Returns true if the specified plugin is installed.
  # If the version is specified, this version is taken into account.
  # If mustequal is true, the version must be a match with the specified version.
  #-----------------------------------------------------------------------------
  def self.installed?(plugin_name, plugin_version = nil, mustequal = false)
    plugin = @@Plugins[plugin_name]
    return false if plugin.nil?
    return true if plugin_version.nil?
    comparison = compare_versions(plugin[:version], plugin_version)
    return true if !mustequal && comparison >= 0
    return true if mustequal && comparison == 0
  end
  #-----------------------------------------------------------------------------
  # Returns the string names of all installed plugins.
  #-----------------------------------------------------------------------------
  def self.plugins
    return @@Plugins.keys
  end
  #-----------------------------------------------------------------------------
  # Returns the installed version of the specified plugin.
  #-----------------------------------------------------------------------------
  def self.version(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:version]
  end
  #-----------------------------------------------------------------------------
  # Returns the link of the specified plugin.
  #-----------------------------------------------------------------------------
  def self.link(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:link]
  end
  #-----------------------------------------------------------------------------
  # Returns the credits of the specified plugin.
  #-----------------------------------------------------------------------------
  def self.credits(plugin_name)
    return if !installed?(plugin_name)
    return @@Plugins[plugin_name][:credits]
  end
  #-----------------------------------------------------------------------------
  # Compares two versions given in string form. v1 should be the plugin version
  # you actually have, and v2 should be the minimum/desired plugin version.
  # Return values:
  #     1 if v1 is higher than v2
  #     0 if v1 is equal to v2
  #     -1 if v1 is lower than v2
  #-----------------------------------------------------------------------------
  def self.compare_versions(v1, v2)
    d1 = v1.split("")
    d1.insert(0, "0") if d1[0] == "."          # Turn ".123" into "0.123"
    while d1[-1] == "."; d1 = d1[0..-2]; end   # Turn "123." into "123"
    d2 = v2.split("")
    d2.insert(0, "0") if d2[0] == "."          # Turn ".123" into "0.123"
    while d2[-1] == "."; d2 = d2[0..-2]; end   # Turn "123." into "123"
    for i in 0...[d1.size, d2.size].max   # Compare each digit in turn
      c1 = d1[i]
      c2 = d2[i]
      if c1
        return 1 if !c2
        return 1 if c1.to_i(16) > c2.to_i(16)
        return -1 if c1.to_i(16) < c2.to_i(16)
      else
        return -1 if c2
      end
    end
    return 0
  end
  #-----------------------------------------------------------------------------
  #  formats the error message
  #-----------------------------------------------------------------------------
  def self.pluginErrorMsg(name, script)
    # begin message formatting
    message  = "[Pokémon Essentials version #{Essentials::VERSION}]\r\n"
    message += "#{Essentials::ERROR_TEXT}\r\n"   # For third party scripts to add to
    message += "Error in Plugin [#{name}]:\r\n"
    message += "#{$!.class} occurred.\r\n"
    # go through message content
    for line in $!.message.split("\r\n")
      next if nil_or_empty?(line)
      n = line[/\d+/]
      err = line.split(":")[-1].strip
      lms = line.split(":")[0].strip
      err.gsub!(n, "") if n
      err = err.capitalize if err.is_a?(String) && !err.empty?
      linum = n ? "Line #{n}: " : ""
      message += "#{linum}#{err}: #{lms}\r\n"
    end
    # show last 10 lines of backtrace
    message += "\r\nBacktrace:\r\n"
    $!.backtrace[0, 10].each { |i| message += "#{i}\r\n" }
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
    t = System.delta
    until (System.delta - t) >= 500000
      Input.update
      if Input.press?(Input::CTRL)
        Input.clipboard = message
        break
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Used to read the metadata file
  #-----------------------------------------------------------------------------
  def self.readMeta(dir, file)
    filename = "#{dir}/#{file}"
    meta = {}
    # read file
    Compiler.pbCompilerEachPreppedLine(filename) { |line, line_no|
      # split line up into property name and values
      if !line[/^\s*(\w+)\s*=\s*(.*)$/]
        raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}", FileLineData.linereport)
      end
      property = $~[1].upcase
      data = $~[2].split(',')
      data.each_with_index { |value, i| data[i] = value.strip }
      # begin formatting data hash
      case property
      when 'REQUIRES'
        meta[:dependencies] = [] if !meta[:dependencies]
        if data.length < 2   # No version given, just push name of plugin dependency
          meta[:dependencies].push(data[0])
          next
        elsif data.length == 2   # Push name and version of plugin dependency
          meta[:dependencies].push([data[0], data[1]])
        else   # Push dependency type, name and version of plugin dependency
          meta[:dependencies].push([data[2].downcase.to_sym, data[0], data[1]])
        end
      when 'EXACT'
        next if data.length < 2   # Exact dependencies must have a version given; ignore if not
        meta[:dependencies] = [] if !meta[:dependencies]
        meta[:dependencies].push([:exact, data[0], data[1]])
      when 'OPTIONAL'
        next if data.length < 2   # Optional dependencies must have a version given; ignore if not
        meta[:dependencies] = [] if !meta[:dependencies]
        meta[:dependencies].push([:optional, data[0], data[1]])
      when 'CONFLICTS'
        meta[:incompatibilities] = [] if !meta[:incompatibilities]
        data.each { |value| meta[:incompatibilities].push(value) if value && !value.empty? }
      when 'SCRIPTS'
        meta[:scripts] = [] if !meta[:scripts]
        data.each { |scr| meta[:scripts].push(scr) }
      when 'CREDITS'
        meta[:credits] = data
      when 'LINK', 'WEBSITE'
        meta[:link] = data[0]
      else
        meta[property.downcase.to_sym] = data[0]
      end
    }
    # generate a list of all script files to be loaded, in the order they are to
    # be loaded (files listed in the meta file are loaded first)
    meta[:scripts] = [] if !meta[:scripts]
    # get all script files from plugin Dir
    for fl in Dir.all(dir)
      next if !fl.include?(".rb")
      meta[:scripts].push(fl.gsub("#{dir}/", ""))
    end
    # ensure no duplicate script files are queued
    meta[:scripts].uniq!
    # return meta hash
    return meta
  end
  #-----------------------------------------------------------------------------
  # Get a list of all the plugin directories to inspect
  #-----------------------------------------------------------------------------
  def self.listAll
    return [] if !$DEBUG || safeExists?("Game.rgssad")
    # get a list of all directories in the `Plugins/` folder
    dirs = []
    Dir.get("Plugins").each { |d| dirs.push(d) if Dir.safe?(d) }
    # return all plugins
    return dirs
  end
  #-----------------------------------------------------------------------------
  # Catch any potential loop with dependencies and raise an error
  #-----------------------------------------------------------------------------
  def self.validateDependencies(name, meta, og = nil)
    # exit if no registered dependency
    return nil if !meta[name] || !meta[name][:dependencies]
    og = [name] if !og
    # go through all dependencies
    for dname in meta[name][:dependencies]
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
  #-----------------------------------------------------------------------------
  # Sort load order based on dependencies (this ends up in reverse order)
  #-----------------------------------------------------------------------------
  def self.sortLoadOrder(order, plugins)
    # go through the load order
    for o in order
      next if !plugins[o] || !plugins[o][:dependencies]
      # go through all dependencies
      for dname in plugins[o][:dependencies]
        # clean the name to a simple string
        dname = dname[0] if dname.is_a?(Array) && dname.length == 2
        dname = dname[1] if dname.is_a?(Array) && dname.length == 3
        # catch missing dependency
        self.error("Plugin '#{o}' requires plugin '#{dname}' to work properly.") if !order.include?(dname)
        # skip if already sorted
        next if order.index(dname) > order.index(o)
        # catch looping dependency issue
        order.swap(o, dname)
        order = self.sortLoadOrder(order, plugins)
      end
    end
    return order
  end
  #-----------------------------------------------------------------------------
  # Get the order in which to load plugins
  #-----------------------------------------------------------------------------
  def self.getPluginOrder
    plugins = {}
    order = []
    # Find all plugin folders that have a meta.txt and add them to the list of
    # plugins.
    for dir in self.listAll
      # skip if there is no meta file
      next if !safeExists?(dir + "/meta.txt")
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
  #-----------------------------------------------------------------------------
  # Check if plugins need compiling
  #-----------------------------------------------------------------------------
  def self.needCompiling?(order, plugins)
    # fixed actions
    return false if !$DEBUG || safeExists?("Game.rgssad")
    return true if !safeExists?("Data/PluginScripts.rxdata")
    Input.update
    return true if Input.press?(Input::CTRL)
    # analyze whether or not to push recompile
    mtime = File.mtime("Data/PluginScripts.rxdata")
    for o in order
      # go through all the registered plugin scripts
      scr = plugins[o][:scripts]
      dir = plugins[o][:dir]
      for sc in scr
        return true if File.mtime("#{dir}/#{sc}") > mtime
      end
      return true if File.mtime("#{dir}/meta.txt") > mtime
    end
    return false
  end
  #-----------------------------------------------------------------------------
  # Check if plugins need compiling
  #-----------------------------------------------------------------------------
  def self.compilePlugins(order, plugins)
    echo 'Compiling plugin scripts...'
    scripts = []
    # go through the entire order one by one
    for o in order
      # save name, metadata and scripts array
      meta = plugins[o].clone
      meta.delete(:scripts)
      meta.delete(:dir)
      dat = [o, meta, []]
      # iterate through each file to deflate
      for file in plugins[o][:scripts]
        File.open("#{plugins[o][:dir]}/#{file}", 'rb') do |f|
          dat[2].push([file, Zlib::Deflate.deflate(f.read)])
        end
      end
      # push to the main scripts array
      scripts.push(dat)
    end
    # save to main `PluginScripts.rxdata` file
    File.open("Data/PluginScripts.rxdata", 'wb') { |f| Marshal.dump(scripts, f) }
    # collect garbage
    GC.start
    echoln ' done.'
    echoln ''
  end
  #-----------------------------------------------------------------------------
  # Check if plugins need compiling
  #-----------------------------------------------------------------------------
  def self.runPlugins
    # get the order of plugins to interpret
    order, plugins = self.getPluginOrder
    # compile if necessary
    self.compilePlugins(order, plugins) if self.needCompiling?(order, plugins)
    # load plugins
    scripts = load_data("Data/PluginScripts.rxdata")
    echoed_plugins = []
    for plugin in scripts
      # get the required data
      name, meta, script = plugin
      # register plugin
      self.register(meta)
      # go through each script and interpret
      for scr in script
        # turn code into plaintext
        code = Zlib::Inflate.inflate(scr[1]).force_encoding(Encoding::UTF_8)
        # get rid of tabs
        code.gsub!("\t", "  ")
        # construct filename
        sname = scr[0].gsub("\\","/").split("/")[-1]
        fname = "[#{name}] #{sname}"
        # try to run the code
        begin
          eval(code, TOPLEVEL_BINDING, fname)
          echoln "Loaded plugin: #{name}" if !echoed_plugins.include?(name)
          echoed_plugins.push(name)
        rescue Exception   # format error message to display
          self.pluginErrorMsg(name, sname)
          Kernel.exit! true
        end
      end
    end
    echoln '' if !echoed_plugins.empty?
  end
  #-----------------------------------------------------------------------------
end
