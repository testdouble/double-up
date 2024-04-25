module Utils
  class HumanizeNames
    def call(names)
      case names.size
      when 0
        ""
      when 1
        names[0]
      when 2
        I18n.t("name_list.two_names", first_name: names[0], second_name: names[1])
      else
        names_before_last = names[0..-2].join(", ")
        last_name = names[-1]
        "#{I18n.t("name_list.many_names.start", names_before_last: names_before_last)}, #{I18n.t("name_list.many_names.end", last_name: last_name)}"
      end
    end
  end
end
