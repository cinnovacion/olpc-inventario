# encoding: UTF-8
#
#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
#                                                                          
# TODO:
# - is checking strings against "null" still needed? This was an old (0.6.1) Qooxdoo
#   bug. 
#
#

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #

class SearchController < ApplicationController
  around_filter :rpc_block

  def initialize(options = nil)
    @clazz_ref = controller_name.classify.constantize
    @search_includes = nil
    if options and options[:includes]
      @search_includes = options[:includes]
    end

    super()
  end

  def search
    send_column_info if params[:need_column_info]
    objects = @clazz_ref
    objects = objects.includes(@search_includes) if !@search_includes.nil?

    page = params[:page] || 1
    per_page = params[:per_page] ? params[:per_page].to_i : 30
    objects = objects.page(page).per_page(per_page)
    objects = handle_ordering(objects)

    client_conditions = extract_conditions()
    objects = objects.where(client_conditions) if client_conditions

    @output["rows"] = format_results(objects)
    @output["results"] = objects.total_entries
    @output["page_count"] = objects.total_pages
    @output["page"] = page
    @output["fecha"] = Date.current.iso8601
    setup_choose_button_options
  end

  def prepare_form(attribs = {})
    @output["fields"] = []
    attribs = attribs.with_indifferent_access

    allowed_attribs = [
      "window_title", "verify_before_save", "verify_save_url", "with_tabs"
    ]
    allowed_attribs.each { |attr|
      @output[attr] = attribs[attr] if attribs.include?(attr)
    }
    if params[:id]
      if attribs[:relation]
        object = attribs[:relation]
      else
        object = @clazz_ref
      end
      object = object.find(params[:id])
      @output["id"] = object.id
      return object
    end
    nil
  end

  def tab_break(label)
    @output["fields"].push({ datatype: "tab_break", title: label })
  end

  def form_field(object, name, datatype, extra_options)
    options = {
      :name => name,
      :datatype => datatype
    }

    options[:value] = object.send(name) if !object.nil?

    @output["fields"].push(options.merge(extra_options))
  end

  def form_combobox(object, name, label, values)
    form_field(nil, name, "combobox", :label => label, :options => values)
  end

  def form_textfield(object, name, label)
    form_field(object, name, "textfield", :label => label)
  end

  def form_password(object, name, label)
    form_field(nil, name, "passwordfield", label: label)
  end

  def form_textarea(object, name, label, attribs = {})
    attribs[:label] = label
    form_field(object, name, "textarea", attribs)
  end

  def form_date(object, name, label)
    form_field(object, name, "date", label: label)
  end

  def form_select(name, option, label, options = [], attribs = {})
    attribs[:label] = label
    attribs[:options] = options
    attribs[:option] = option
    form_field(nil, name, "select", attribs)
  end

  def form_place_selector(object, name, label, options)
    # FIXME internal implementation quite inconsistent with other elements
    # the options should just go in the main hash, and why can't we just pass
    # a value as normal?
    attribs = { label: label }
    attribs[:options] = options if !options.blank?
    attribs[:dataHash] = object.place.getElementsHash if !object.nil?
    form_field(nil, name, "hierarchy_on_demand", attribs)
  end

  def form_label(label, text)
    label = {
      datatype: "label",
      label: label,
      text: text.to_s
    }
    @output["fields"].push(label)
  end

  def form_details_link(label, option, id, text)
    element = {
      datatype: "abmform_details",
      label: label,
      option: option,
      id: id,
      text: text.to_s
    }
    @output["fields"].push(element)
  end

  def form_uploadfield(label, field_name)
    element = {
      datatype: "uploadfield",
      label: label,
      field_name: field_name
    }
    @output["fields"].push(element)
  end

  # Default save method: directly update the model with attribs from the
  # payload.
  def save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    if data["id"]
      version = @clazz_ref.find(data["id"]).update_attributes!(attribs)
    else
      @clazz_ref.create!(attribs)
    end

    @output["msg"] = data["id"] ? _("Changes saved.") : _("Information added.")
  end

  # Default delete method: delete matching IDs
  def delete
    ids = JSON.parse(params[:payload])
    @clazz_ref.destroy(ids)
    @output["msg"] = "Elements deleted."
  end

  private

  # Given a field, determine the database column name, for use in
  # ORDER BY and WHERE clauses, etc.
  def get_db_column(field)
    return nil if field[:column].blank?

    if field[:association].present?
      # If using an association, reflect and look up table name
      reflection = @clazz_ref.reflect_on_association(field[:association])
      if reflection.options.include?(:class_name)
        assoc_class = reflection.options[:class_name]
      else
        assoc_class = reflection.name.to_s
      end
      assoc_class = classify_singular(assoc_class).constantize
      return assoc_class.table_name + "." + field[:column].to_s
    end

    # Assume the field is in the current table
    return controller_name + "." + field[:column].to_s
  end

  def handle_ordering(objects)
    fields = @clazz_ref::FIELDS
    sort_column = 0
    sort = "asc"

    if params[:sort_column].present?
      # apply user-selected sort
      sort_column = params[:sort_column].to_i
      sort = params[:sort] if params[:sort].present?
    else
      # model specifies default sort via one column having :default_sort set
      fields.each_with_index { |field, i|
        if field[:default_sort]
          sort_column = i
          if [String, Symbol].include?(field[:default_sort].class)
            sort = field[:default_sort].to_s
          end
          break
        end
      }
    end

    order = get_db_column(fields[sort_column])
    return objects if order.nil?
    
    @output["sort_column"] = sort_column
    @output["sort"] = sort
    order += " " + sort
    objects.order(order)
  end

  # Create the data needed for the combobox the lets the user search by 
  # different criteria in our Listings. 
  def send_column_info
    @output["columns"] = @clazz_ref::FIELDS.map { |col|
      tmp = col.slice(:name, :default_search, :visible, :width)

      db_column = get_db_column(col)
      tmp[:db_column] = db_column if db_column

      if col.include?(:attribute)
        # if we are dealing with an attribute-accessed field, we cannot
        # offer DB-driven search functionality on that field
        tmp[:searchable] = false

        # if our attribute field has no column info, we can't sort either
        tmp[:sortable] = false if !col.include?(:column)
      end
      tmp
    }
  end

  ####
  # Config option for the 'Choose' button. 
  #
  def setup_choose_button_options()
    if @clazz_ref.respond_to?(:getChooseButtonColumns)
      h = @clazz_ref.getChooseButtonColumns
      h = h.with_indifferent_access
      if h[:desc_col].class.to_s == "Fixnum"
        h[:desc_col] = {:columnas => [h[:desc_col]],:separator => ""}
      end
      @output["elegir_data"] = h
    end
  end


  def format_results(objects)
    objects.map { |obj|
      @clazz_ref::FIELDS.map { |c| 
        # Always use :attribute value if provided
        next eval("obj." + c[:attribute].to_s + ".to_s") if c[:attribute].present?

        # Look up value from association
        if c[:association].present?
          tmp = obj.send(c[:association])
          next "" if !tmp
          next tmp.send(c[:column]).to_s
        end

        # Its a column in the local table
        next obj.send(c[:column]).to_s
      }
    }
  end

  # extract the conditions sent by the client request and 
  # return them in ActiveRecords conditions format
  def extract_conditions()
    payload = params[:payload] ? JSON.parse(params[:payload]) : {}
    cond = [""]
    condStrArr = []

    payload.keys.each { |key|
      oprLen = payload[key]["operators"].length
      valLen = payload[key]["values"].length
    
      # we treat letter with/without accents indistinctively. 
      payload[key]["values"].map { |m|
        begin
            m.gsub!(/n|ñ/,'(n|ñ)')
            m.gsub!(/a|á/,'(a|á)')
            m.gsub!(/e|é/,'(e|é)')
            m.gsub!(/i|í/,'(i|í)')
            m.gsub!(/o|ó/,'(o|ó)')
            m.gsub!(/u|ú/,'(u|ú)')
        rescue
        end
      }
    
      oprArr = []
      (valLen / oprLen).times do
        subOprStr = payload[key]["operators"].map { |opr|
          " #{key} #{opr} "
        }.join(" and ")
        oprArr.push("(#{subOprStr})")
      end
      oprStr = oprArr.join(" or ")
      condStrArr.push("(#{oprStr})")
      cond += payload[key]["values"]
    }

    cond[0] = condStrArr.join(" and ")
    cond
  end

  # Like classify but takes a singular table name as input
  def classify_singular(table_name)
    table_name.to_s.camelize.sub(/.*\./, '')
  end

end
