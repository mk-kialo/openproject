#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

# Restricts loaded locales to :en to avoid a 2-seconds penalty when locales are
# loaded.
#
# Additional locales are lazily loaded when:
# - +Redmine::I18n#all_attribute_translations+ is called
# - +Redmine::I18n#ll+ is called
# - +Redmine::I18n#set_language_if_valid+ is called
# - +I18n.with_locale+ is called
module I18nLazyLoadingPatch
  # overrides Redmine::I18n
  def all_attribute_translations(locale)
    I18nLazyLoadingPatch.load_locale(locale)
    super
  end

  # overrides Redmine::I18n
  def ll(lang, _str, _value = nil)
    I18nLazyLoadingPatch.load_locale(lang)
    super
  end

  # overrides Redmine::I18n
  def set_language_if_valid(lang)
    if locale = find_language(lang)
      I18nLazyLoadingPatch.load_locale(locale)
    end
    super
  end

  # overrides I18n
  def with_locale(locale)
    I18nLazyLoadingPatch.load_locale(locale)
    super
  end

  def self.install
    # copy original I18n load path
    @@original_load_path = I18n.config.load_path.dup
    # restrict available locales to :en
    I18n.config.load_path = load_path(:en)
    # Hook into Redmine::I18n
    Redmine::I18n.prepend(self)
    # Hook into I18n
    I18n.singleton_class.prepend(self)
  end

  def self.load_locale(locale)
    locale = locale.to_sym
    return if ::I18n.config.available_locales_set.include?(locale)

    I18n.backend.load_translations(load_path(locale))
    I18n.config.clear_available_locales_set
  end

  def self.load_path(locale)
    file_regex = /#{locale}\.(rb|yml)$/
    @@original_load_path.grep(file_regex)
  end
end

RSpec.configure do
  I18nLazyLoadingPatch.install
end
