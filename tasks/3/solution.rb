class CommandParserBase
  def initialize(command_name)
    @command_name = command_name
    @operations = []
    @arguments = []
    @options = {}
    @options_with_params = {}
  end

  protected
  def handle_option_with_param(command_runner, name)
    if name.include? "="
      option = (name.split "=")[0]
      argument = (name.split "=")[1]
    else
      option = @options_with_params[name.slice 0, 2]
      argument = name.slice 2, name.size
    end
    @options_with_params[option]["block"].call command_runner, argument
  end

  def handle_option_without_param(command_runner, name)
    name = @options[name] unless full_name_option? name
    @options[name]["block"].call command_runner, true
  end

  def handle_option(command_runner, name)
    if with_param? name
      handle_option_with_param command_runner, name
    else
      handle_option_without_param command_runner, name
    end
  end
end

class CommandParser < CommandParserBase
  def initialize(command_name)
    super(command_name)
  end

  def argument(file_name, &block)
    @operations << block
    @arguments << file_name
  end

  def option(short_name, full_name, description, &block)
    option = {}
    add_options(option, @options, short_name, full_name, description, &block)
  end

  def option_with_parameter(short_name, full_name,
                            description, placeholder, &block
                           )
    option_with_param = { "placeholder" => placeholder }
    add_options(
      option_with_param, @options_with_params,
      short_name, full_name, description, &block
    )
  end

  def parse(command_runner, argv)
    argument_index = 0
    argv.each_index do |index|
      if option? argv[index]
        handle_option command_runner, argv[index]
      else
        @operations[argument_index].call command_runner, argv[index]
        argument_index += 1
      end
    end
  end

  def help
    CommandParserHelper.new(
      @command_name, @arguments, @options, @options_with_params
    ).help
  end

  private
  def option?(name)
    name.start_with? "-"
  end

  def full_name_option?(name)
    name.start_with? "--"
  end

  def with_param?(name)
    (name.include? "=") || (@options.key? (name.slice 0, 2))
  end

  def add_options(current_option, all_options, short_name,
                  full_name, description, &block
                 )
    current_option["short_name"] = "-" + short_name
    current_option["full_name"] = "--" + full_name
    current_option["description"] = description
    current_option["block"] = block

    all_options["-" + short_name] = "--" + full_name
    all_options["--" + full_name] = current_option
  end
end

class CommandParserHelper
  def initialize(command_name, arguments, options, options_with_params)
    @command_name = command_name
    @arguments = arguments
    @options = options
    @options_with_params = options_with_params
  end

  def help
    result = "Usage: #{@command_name} ["
    @arguments.each { |arg| result += arg }
    result += "]\n    "
    result += options_help
    result += options_with_params_help
    result
  end

  private
  def options_help
    result = ""
    @options.keys.each_slice(2) do |pair|
      result += "#{pair[0]}, #{pair[1]} "
      result += "#{@options[pair[1]]['description']}\n    "
    end
    result
  end

  def options_with_params_help
    result = ""
    @options_with_params.keys.each_slice(2) do |pair|
      result += "#{pair[0]}, #{pair[1]}="
      result += "#{@options_with_params[pair[1]]['placeholder']} "
      result += "#{@options_with_params[pair[1]]['description']}\n"
    end
    result
  end
end