#==============================================================================#
#                                Plugin Manager                                #
#                                  by Marin                                    #
#------------------------------------------------------------------------------#
#   Provides a simple interface that allows plugins to require dependencies    #
#   at specific versions, and to specify incompatibilities between plugins.    #
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
# A plugin's version is typically in the format X.Y.Z, but the number of       #
# digits does not matter. You can also use Xa, Xb, Xc, Ya, etc.                #
# What matters is that you use it consistently, so that it can be compared.    #
#                                                                              #
#                                                                              #
#                                                                              #
# Now let's say we create a new plugin titled "Simple Extension", which        #
# requires our previously created "Basic Plugin" to work.                      #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Simple Extension",                                        #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => ["Marin", "Maruno"],                                       #
#       :dependencies => ["Basic Plugin"]                                      #
#     })                                                                       #
#                                                                              #
# This plugin has two credits as an array, instead of one string. Furthermore, #
# this code will ensure that "Basic Plugin" is installed, ignoring its         #
# version. If you have only one dependency, you can omit the array brackets    #
# like so:                                                                     #
#                                                                              #
#     :dependencies => "Basic Plugin"                                          #
#                                                                              #
#                                                                              #
#                                                                              #
# To require a minimum version of a dependency plugin, you should turn the     #
# dependency's name into an array which contains the name and the version      #
# (both as strings). For example, to require "Basic Plugin" version 1.2 or     #
# higher, you would write:                                                     #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Simple Extension",                                        #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => "Marin",                                                   #
#       :dependencies => [                                                     #
#         ["Basic Plugin", "1.2"]                                              #
#       ]                                                                      #
#     })                                                                       #
#                                                                              #
#                                                                              #
#                                                                              #
# To require a specific version (no higher and no lower) of a dependency       #
# plugin, you should add the :exact flag as the first thing in the array for   #
# that dependency:                                                             #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Simple Extension",                                        #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => "Marin",                                                   #
#       :dependencies => [                                                     #
#         [:exact, "Basic Plugin", "1.2"]                                      #
#       ]                                                                      #
#     })                                                                       #
#                                                                              #
#                                                                              #
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
#                                                                              #
#                                                                              #
# If your plugin can work without another plugin, but is known to be           #
# incompatible with an old version of that other plugin, you should list it as #
# an optional dependency. If that other plugin is present in a game, then this #
# optional dependency will ensure it meets the minimum version required for    #
# your plugin. Write it in the same way as any other dependency as described   #
# above, but use the :optional flag instead.                                   #
# You do not need to list a plugin as an optional dependency at all if all     #
# versions of that other plugin are compatible with your plugin.               #
#                                                                              #
#     PluginManager.register({                                                 #
#       :name    => "Other Plugin",                                            #
#       :version => "1.0",                                                     #
#       :link    => "https://reliccastle.com/link-to-the-plugin/",             #
#       :credits => "Marin",                                                   #
#       :dependencies => [                                                     #
#         [:optional, "QoL Improvements", "1.1"]                               #
#       ]                                                                      #
#     })                                                                       #
#                                                                              #
# The :optional_exact flag is a combination of :optional and :exact.           #
#------------------------------------------------------------------------------#
#                     Please give credit when using this.                      #
#==============================================================================#

module PluginManager
  # Win32API MessageBox function for custom errors.
  MBOX = Win32API.new('user32', 'MessageBox', ['I','P','P','I'], 'I')
  # Holds all registered plugin data.
  @@Plugins = {}

  # Registers a plugin and tests its dependencies and incompatibilities.
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
              when :optional;       optional = true
              when :exact;          exact    = true
              when :optional_exact; optional = true; exact = true
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

  # Throws a pure error message without stack trace or any other useless info.
  def self.error(msg)
    Graphics.update
    t = Thread.new do
      MBOX.call(Win32API.pbFindRgssWindow, msg, "Plugin Error", 0x10)
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
end
