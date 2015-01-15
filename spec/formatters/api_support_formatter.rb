require 'rspec/core/formatters/documentation_formatter'

# Formatter to support documenting currently-implemented API paths and
# methods. This borrows heavily from the standard
# DocumentationFormatter, but excludes example groups not related
# tagged with :support. It also formats examples with a :method tag
# with the HTTP method and path ahead of the example description.
class ApiSupportFormatter < RSpec::Core::Formatters::DocumentationFormatter

  def example_group_started(example_group)
    super(example_group) if describes_support?(example_group)
  end

  def example_group_finished(example_group)
    super(example_group) if describes_support?(example_group)
  end

  def failure_output(example, exception)
    red("#{current_indentation}F #{example.description} (FAILED - #{next_failure_index})")
  end

  def passed_output(example)
    green("#{current_indentation}#{example_output_text(example)}")
  end

  def pending_output(example, message)
    yellow("#{current_indentation}* #{example_output_text(example)} (PENDING)")
  end

protected

  def example_output_text(example)
    if example.metadata[:method]
      example_group_text = ''
      example_group_text = @example_group.description if @example_group.description =~ /^\//
      output = "#{example.metadata[:method]} #{example_group_text} - #{example.description}"
    else
      output = example.description # consider no output for examples not tagged with a :method
    end
  end

  def describes_support?(example_group)
    example_group.metadata.filter_applies?(:support, true)
  end

end
