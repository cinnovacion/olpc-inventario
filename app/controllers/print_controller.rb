#     Copyright Paraguay Educa 2009, 2010
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
# print_controller: Based on HTMLDoc ( http://wiki.rubyonrails.org/rails/pages/HowtoGeneratePDFs )
#
#
# Author: Raúl Gutiérrez - rgs@paraguayeduca.org
# Author: Martin Abente - mabente@paraguayeduca.org
#
#
# TODO:
# - maybe the data gathering and calculation shouldn't be here. Perhaps in a module in lib/ ?
# - setting the variable 'nombre' could be infered and setup automatically
# - the imprimir function could be called automatically by an 'after' hook
#

require 'fecha'
require 'py_educa_graph'

class PrintController < ApplicationController

  #
  # Jodido, al parecer el data scoping sobre-escribe el include? (tch)
  # skip_filter :do_scoping
  #
  # FIXME: is (commenting) this save?!? (rgs)

  def initialize 
    @image_name = nil
  end


  def test_print_report
    print_params = JSON.parse(params[:print_params]).reverse

    # combobox de clubes
    val = print_params.pop

  end

  def lot_information
    print_params = JSON.parse(params[:print_params]).reverse

    lot_id = print_params.pop
    lot = Lot.find_by_id(lot_id)

    @titulo = _("Lot information")
    @titulo +=  "<br> #{_("Responsible")}: #{lot.person.getFullName} <br>"
    @titulo += "<br> #{_("Delivered")}: #{lot.delivery_date} <br>" if lot.delivery_date
    @columnas = [_("Location"), _("Laptops"), _("Owner"), _("Document ID"), _("Serial number")]
    @datos = []

    lot.section_details.each { |section_detail|

      place = section_detail.place
      size = section_detail.laptop_details.length

      @datos.push([place.getName, size, "", "", ""])

      section_detail.laptop_details.each { |laptop_detail|

        owner = laptop_detail.person
        laptop = laptop_detail.laptop
        @datos.push(["", "", owner.getFullName, owner.getIdDoc, laptop.serial_number])
      }
    }

    print(params, "lot_information")
  end

  def stock_status_report
    print_params = JSON.parse(params[:print_params]).reverse
    movements = PartMovement.includes(:place, :part_type, :part_movement_type)

    root_place_id = print_params.pop.to_i
    if root_place_id != -1
      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      movements = buildComboBoxQuery(movements, places_ids, "place_id") 
    end

    stock_status = {}

    PartType.all.each { |part_type|
      stock_status[part_type] = { true => 0, false => 0 }
    }

    movements.each { |part_movement|
      stock_status[part_movement.part_type][part_movement.part_movement_type.direction] += part_movement.amount
    }

    @titulo = _("Estado del stock en %s") % root_place.getName
    @columnas = [_("Part"), _("Incoming"), _("Outgoing"), _("Difference")]
    @datos = []
    
    stock_status.keys.each { |part_type|
      values = stock_status[part_type]
      @datos.push([part_type.description, values[true], values[false], values[true]-values[false]])
    }

    print(params, "stock_status_report")
  end

  def audit_report
    print_params = JSON.parse(params[:print_params]).reverse
    audits = Audit.order("created_at ASC")

    timeRange = print_params.pop
    audits = buildDateQuery(audits, timeRange, "created_at")

    auditable_type = print_params.pop
    audits = audits.where(:auditable_type => auditable_type)

    @titulo = _("Audit at %s") % auditable_type
    @columnas = [_("Date"), _("User"), _("Id"), _("Column"), _("Before"), _("After")]
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @datos = []

    audits.each { |audit_row|
      username = audit_row.user ? audit_row.user.usuario : "System"
      date = audit_row.created_at.to_s
      id = audit_row.auditable_id
      changes = audit_row.changes
      @datos.push([date, username, id, "", "", ""])

      changes.keys.each { |column|
        if changes[column].is_a?(Array)
          old_value = changes[column][0]
          new_value = changes[column][1]
        else
          old_value = ""
          new_value = changes[column]
        end
        @datos.push(["", "", "", column, old_value, new_value])          
      }
    }

    print(params, "Audit_report")
  end

  def average_solved_time

    print_params = JSON.parse(params[:print_params]).reverse
    reports = ProblemReport.where("problem_reports.solved_at is not NULL")

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "created_at")  

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      reports = buildComboBoxQuery(reports, places_ids, "place_id")
    end

    time_min = false
    time_max = false
    time_acum = 0
    time_count = 0
    reports.each { |report|
      time_diff = (report.solved_at.to_date - report.created_at).days.to_i
      time_diff = time_diff > 0 ? (time_diff/3600/24)+1 : 1
      time_min = time_diff if not time_min or time_diff < time_min
      time_max = time_diff if not time_max or time_diff > time_max
      time_acum += time_diff
      time_count += 1
    }

    @titulo = _("Average repair time")
    @titulo += "  en #{root_place.getName}" if root_place
    @columnas = [_("Value"), _("Days")]
    @datos = [

      [_("Max"), time_max],
      [_("Min"), time_min],
      [_("Avg"), time_acum.to_f/time_count.to_f]
    ]

    print(params, _("Average time"))
  end

  def laptops_problems_recurrence

    print_params = JSON.parse(params[:print_params]).reverse    
    people = Person.includes(:laptops => :problem_reports)

    timeRange = print_params.pop
    people = buildDateQuery(people, timeRange, "problem_reports.created_at")

    root_place_id = print_params.pop.to_i
    if root_place_id != -1
      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      people = buildComboBoxQuery(people, places_ids, "problem_reports.place_id")
    end

    results = [0,0,0,0,0]
    results.each_index { |index|
      people.each { |person|
        person.laptops.each { |laptop|
          if laptop.problem_reports.length > index
            results[index]+=1
          end
        }
      }
    }

    @titulo = _("Recurrence table")
    @titulo += "  en #{root_place.getName}" if root_place
    @columnas = [_("Quantity"), _("Total")]
    @datos = []
    graph_data = []
    graph_labels = {}

    results.each_index { |index|
      @datos.push([index+1, results[index]])
      graph_labels[index] = (index+1).to_s
    }

    graph_data.push({ :name => _("Values"), :value => results })
    @image_name = "/" + PyEducaGraph::createLine(graph_data, "Recurrences (inclusive)", graph_labels)
    print(params, _("Recurrence problems"))
  end

  def is_hardware_dist
    print_params = JSON.parse(params[:print_params]).reverse
    reports = ProblemReport.includes(:problem_type)

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "created_at")

    root_place_id = print_params.pop.to_i
    if root_place_id != -1
      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      reports = buildComboBoxQuery(reports, places_ids, "place_id")
    end

		solved = print_params.pop
    reports = reports.where(:solved => solved)

    results = { true => 0, false => 0 }
    reports.each { |report|
      problem_class = report.problem_type.is_hardware
      results[problem_class] += 1
    }

    @titulo = _("Problem dist. (Hardware vs Software)")
    @titulo += _("  in %s") % root_place.getName if root_place
    @columnas = [_("Type"), _("Quantity"), _("%")]
    @datos = []
    graph_data = []

    total = results[true] + results[false]
    hardware_percent = "%4.1f" % ((results[true]*100).to_f/total.to_f)
    software_percent = "%4.1f" % ((results[false]*100).to_f/total.to_f)

    @datos.push([_("Hardware"), results[true], hardware_percent])
    graph_data.push({ :name => _("Hardware"), :value => hardware_percent.to_f })

    @datos.push([_("Software"), results[false], software_percent])
    graph_data.push({ :name => _("Software"), :value => software_percent.to_f })

    @image_name = "/" + PyEducaGraph::createPie(graph_data, _("Distribution"))
    print(params, "distribution_hardware_software")
  end

  def problems_time_distribution

    print_params = JSON.parse(params[:print_params]).reverse    
    reports = ProblemReport.includes(:problem_type, {:laptop => :model})

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "created_at")

    window_size = print_params.pop

    root_place_id = print_params.pop.to_i
    if root_place_id != -1
      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      reports = buildComboBoxQuery(reports, places_ids, "place_id")
    end

    problem_types_ids = print_params.pop
    reports = buildComboBoxQuery(reports, problem_types_ids, "id")

    laptops_models_ids = print_params.pop
    reports = buildComboBoxQuery(reports, laptops_models_ids, "models.id")
    laptops_models = Model.where(:id => laptops_models_ids)

    results = Hash.new

    group_method = "beginning_of_#{window_size}"
    since = timeRange["date_since"].to_date.send(group_method)
    to = timeRange["date_to"].to_date.send(group_method)

    ProblemType.where(:id => problem_types_ids).each { |problem_type|
      results[problem_type] = Hash.new
      aux_window = since
      while aux_window <= to
        results[problem_type][aux_window] = 0
        aux_window += 1.send(window_size)
      end
    }
   
    reports.each { |problem_report|
      problem_type = problem_report.problem_type
      time_window = problem_report.created_at.send(group_method)

      results[problem_type][time_window] = results[problem_type][time_window] ? results[problem_type][time_window]+1 : 1
    }

    @titulo = root_place.getName
    @titulo += "<br>"  + _("Distribucion en el tiempo de los problemas") + "</br>"
    @titulo += "<br><small>(#{laptops_models.collect(&:name).join(',')})</small></br>"

    ventana = ""
    case window_size
      when "day"
        ventana = _("Day")
      when "week"
        ventana = _("Week")
      when "month"
        ventana = _("Month")
      when "year"
        ventana = _("Year")
    end

    @columnas = [_("Problem"), ventana, _("Quantity"), _("Average"), _("Acumulated"), _("%(Total)"), _("Laptops"), _("Frequency"), _("Avg Frequency")]
    @datos = []
    graph_labels = Hash.new
    graph_data = Array.new

    laptop_query = Laptop.includes({:owner => :performs}, :model)
    laptop_query = laptop_query.where("performs.place_id in (?) and models.id in (?)", places_ids, laptops_models_ids)

    x_problem_type = results.keys.first
    tabla_tornasol = results[x_problem_type].keys.sort.map { |time_window| 
      laptop_query.where("laptops.created_at <= ?", time_window.send("end_of_#{window_size}")).count
    }

    results.keys.each { |problem_type| 
      @datos.push([problem_type.name,"", "", "", "", ""])
      values = []
      sub_total = 0
      average = 0
      aux_average = 0
      weights = 0
      frequency = 0
      acumulated_frequency = 0
      avg_frequency = 0

      results[problem_type].keys.sort { |a,b| a < b ? -1 : 1 }.each_with_index { |time_window, index| 

        indice = results[problem_type][time_window]

        laptops_in_window = tabla_tornasol[index].to_f
        sub_total += indice
        weights += laptops_in_window
        aux_average += (indice.to_f * laptops_in_window)
        average = "%4.1f" % (aux_average / weights)
        indice_tornasol = "%4.1f" % ((sub_total.to_f / laptops_in_window) * 100.to_f)
        frequency = (laptops_in_window > 0) ? (indice / laptops_in_window) : 0
        acumulated_frequency += frequency
        avg_frequency = "%4.7f" % (acumulated_frequency.to_f / (index + 1).to_f)
        printable_frequency = "%4.7f" % frequency

        @datos.push(["", time_window.to_s, indice, average, sub_total,indice_tornasol, tabla_tornasol[index], printable_frequency, avg_frequency])
        values.push(average.to_f)
        graph_labels[index] = time_window.to_s
      }
    
      graph_data.push({ :name => problem_type.name, :value => values })

    }


    @image_name = "/" + PyEducaGraph::createLine(graph_data, _("Average trend"), graph_labels)
    print(params, "problems_time_distribution")
  end

  def deposits

    print_params = JSON.parse(params[:print_params]).reverse
    deposits = BankDeposit.includes({:problem_solution => :problem_report})

    timeRange = print_params.pop
    deposits = buildDateQuery(deposits, timeRange, "bank_deposits.deposited_at")
    
    root_place_id = print_params.pop.to_i
    root_place =  Place.find_by_id(root_place_id)
    places_ids = root_place.getDescendantsIds.push(root_place_id)

    deposits = buildComboBoxQuery(deposits, places_ids, "problem_reports.place_id")

    results = Hash.new
    deposits.order("bank_deposits.deposited_at ASC").each { |bank_deposit|
      results[bank_deposit.deposit] = Array.new if !results[bank_deposit.deposit]
      row = [
              bank_deposit.amount,
              bank_deposit.bank,
              bank_deposit.deposited_at
            ]

      results[bank_deposit.deposit].push(row) 
    }

    @titulo = _("Deposits in %s") % root_place.getName
    @columnas = [_("Deposit"), _("Quantity"), _("Bank"), _("Date")]
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @datos = []
    
    results.keys.each { |key|

      results[key].each { |row|
      
        @datos.push([key]+row)
      }
    }

    print(params, "deposits")
  end

  def problems_and_deposits

    print_params = JSON.parse(params[:print_params]).reverse
    reports = ProblemReport.includes({:problem_solution => [:solution_type, :bank_deposits]}, :problem_type, :owner)

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "problem_reports.created_at")
    
    root_place_id = print_params.pop.to_i
    root_place =  Place.find_by_id(root_place_id)
    places_ids = root_place.getDescendantsIds.push(root_place_id)

    reports = buildComboBoxQuery(reports, places_ids, "problem_reports.place_id")

    status = print_params.pop
    reports = reports.where(:solved => status)

    results = Hash.new
    results[true] = Array.new
    results[false] = Array.new

    reports.order("problem_reports.created_at ASC").each { |problem_report|
      solved = problem_report.solved

      problem_type = problem_report.problem_type
      owner = problem_report.owner
      place = problem_report.place
      laptop = problem_report.laptop

      problem_solution = problem_report.problem_solution
      bank_deposits = problem_solution ? problem_solution.bank_deposits : nil

      row = [
              (solved ? _("Yes") : _("No")),
              problem_type.name,
              owner.getFullName,
              place.getName,
              laptop.serial_number,
              problem_report.created_at.to_s,
              (problem_solution ? problem_solution.created_at.to_s : ""),
              (bank_deposits ? bank_deposits.map { |bank_deposit| bank_deposit.deposit }.join(",") : "" )
            ]

      results[solved].push(row)
    }

    @titulo = "Problems in " % root_place.getName
    @columnas = ["#", _("Solved"), _("Problem"), _("Person"), _("Location"), _("Serial Num."), _("Report"), _("Solution"), _("Deposits")]
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @fontsize = 0.5
    @datos = []

    row_count = 1
    results[true].each { |row|
    
      @datos.push([row_count]+row)
      row_count += 1
    }

    @datos.push(["-","-","-","-","-","-","-","-"])

    results[false].each { |row|

      @datos.push([row_count]+row)
      row_count += 1  
    }

    print(params, "problems_and_deposits")
  end

  def students_ids_distro
    print_params = JSON.parse(params[:print_params]).reverse

    people = Person.includes({:performs => [:place, :profile]})
    people = people.where("profiles.internal_tag = 'student'")

    timeRange = print_params.pop
    people = buildDateQuery(people, timeRange, "people.created_at")

    group_criteria = print_params.pop
    if ["day","week","month","year"].include?(group_criteria)
      group_method = "beginning_of_"+group_criteria
    else
      raise _("Not allowed")
    end

    place = nil
    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      if place
        people = people.where("performs.place_id in (?)", place.getDescendantsIds.push(place_id))
      end
    end

    since  = timeRange["date_since"].to_date.send(group_method)
    to = timeRange["date_to"].to_date.send(group_method)

    results = Hash.new
    aux_window = since.dup
    while (aux_window <= to)
      results[aux_window] = Hash.new
      results[aux_window][:registered_this_window] = 0
      results[aux_window][:created_this_window] = 0
      results[aux_window][:created_until_window] = 0
      results[aux_window][:registered_until_window] = 0
      aux_window += 1.send(group_criteria)
    end

    people.each { |person|
      registered = person.id_document_created_at
      registered_window = registered ? registered.send(group_method) : nil
      created_window = person.created_at.send(group_method)

      if registered
        results[registered_window][:registered_this_window] += 1
      end

      results[created_window][:created_this_window] += 1
    }

    @titulo = _("Number of document ids generated") + "<br>"
    @titulo += "#{place.getName}\n" if place
    @fecha_desde = since
    @fecha_hasta = to
    @columnas = [group_criteria, _("Partially documented"), _("Partial students"), _("Total documented"), _("Total students"), _("Total not documented"), "%"]
    @datos = []
    graph_data = []

    registered_total = 0
    created_total = 0
    aux_window = since.dup
    while (aux_window <= to)

      window = (group_criteria != "week") ? aux_window.send(group_criteria) : aux_window.to_s
      registered_total += results[aux_window][:registered_this_window]
      created_total += results[aux_window][:created_this_window]
      results[aux_window][:registered_until_window] = registered_total
      results[aux_window][:created_until_window] = created_total
      non_registered_total = created_total - registered_total
      percent = ("%0.2f" % ((created_total) ? (registered_total.to_f / created_total.to_f) : 0.to_f)).to_f * 100

      @datos.push([
                    window,
                    results[aux_window][:registered_this_window],
                    results[aux_window][:created_this_window],
                    registered_total,
                    created_total,
                    non_registered_total,
                    percent
      ])
      
      graph_data.push({ :name => window, :value => percent })
      aux_window += 1.send(group_criteria)
    end

    @image_name = "/" + PyEducaGraph::createBar(graph_data, _("Graph"), { :min => 0, :max => 100 })
    print(params, "students_ids_distro")
  end

  def serials_per_places
    print_params = JSON.parse(params[:print_params]).reverse

    places_ids = print_params.pop
    places = nil
    if places_ids != []
      places = Place.where(:id => places_ids)
    end

    root_places = []
    places.each { |root|

      isRoot = true
      places.each { |place|
        isRoot = false if root != place && place.getDescendantsIds.include?(root.id)
      }
   
      root_places.push(root) if isRoot
    }

    @titulo = _("Serial numbers by location")
    @columnas = [_("Location"), _("Total"), _("Entries")]
    @datos = []

    root_places.each { |root|
      serials = root.getLaptopSerials
      @datos.push([root.getName, serials.length.to_s])
      serials.each { |serial|
        @datos.push(["","",serial])
      }
    }

    print(params, "serials_per_places")
  end

  def online_time_statistics
    print_params = JSON.parse(params[:print_params]).reverse

    #A title hack...
    events = Event.includes(:event_type)
    events = events.where("event_types.internal_tag in (?) and (events.extended_info like ? or events.extended_info like ?)", ["node_up","node_down"], "%\"type\": \"server\"%", "%\"type\": \"ap\"%")

    timeRange = print_params.pop
    range_start = timeRange["date_since"].to_date.beginning_of_day.to_time
    range_end = timeRange["date_to"].to_date.end_of_day.to_time
    events = events.where("events.created_at > ? and events.created_at < ?", range_start, range_end)

    root_place_id = print_params.pop.to_i
    root_place = Place.find_by_id(root_place_id)
    raise _("Place not found") if !root_place
    root_places_ids = root_place.getDescendantsIds.push(root_place_id)

    results = Hash.new
    Place.find_all_by_id(root_places_ids).each { |place|
      #finding the parent place and grouping by them...
      place_ids = place.getAncestorsIds.push(place.id)
      parent_q = Place.includes(:place_type)
      parent_q = parent_q.where("places.id in (?) and place_types.internal_tag = 'school'", place_ids)
      parent_place = parent_q.first   

      #Grouping...
      if parent_place && !results[parent_place]

        results[parent_place] = Hash.new
        nodes = Node.includes(:place, :node_type)
        nodes = nodes.where("places.id in (?) and node_types.internal_tag not in ('center')", parent_place.getDescendantsIds.push(parent_place.id))

        #Creating nodes entries....
        nodes.each { |node|
          results[parent_place][node] = Hash.new
          results[parent_place][node][:ranges] = Array.new
          results[parent_place][node][:ranges].push( { :range_start => range_start } )
          results[parent_place][node][:ranges].last.merge!({ :waiting_to_close => true })
          results[parent_place][node][:changed_type] = false
        }    
      end
    }

    events.order("events.created_at ASC").each { |event|
      info = event.getHash
      node = Node.find_by_id(info["id"])

      if node && root_places_ids.include?(node.place_id)

        place = Place.find_by_id(node.place_id)
        if place

          place_ids = place.getAncestorsIds.push(place.id)
          parent_place = Place.includes(:place_type)
          parent_place = parent_place.where("places.id in (?) and place_types.internal_tag = 'school'", place_ids)
          parent_place = parent_place.first

          if parent_place

            #if !results[parent_place]

              #results[parent_place] = Hash.new
              #inc = [:place]
              #cond = ["places.id in (?)", parent_place.getDescendantsIds.push(parent_place.id)]
              #Node.find(:all, :conditions => cond, :include => inc).each { |node|

                #results[parent_place][node] = Hash.new
                #results[parent_place][node][:ranges] = Array.new
                #results[parent_place][node][:ranges].push( { :range_start => range_start } )
                #results[parent_place][node][:ranges].last.merge!({ :waiting_to_close => true })
              #} 
            #end

            #if !results[parent_place][node]
              #results[parent_place][node] = Hash.new
              #results[parent_place][node][:ranges] = Array.new
              #results[parent_place][node][:ranges].push( { :range_start => range_start } )
              #results[parent_place][node][:ranges].last.merge!({ :waiting_to_close => true })
            #end

            results[parent_place][node][:changed_type] = true
            case event.event_type.internal_tag
              when "node_up"
                if results[parent_place][node][:ranges].last[:waiting_to_close]
                  results[parent_place][node][:ranges].last[:range_start] = event.created_at
                else
                  results[parent_place][node][:ranges].push( { :range_start => event.created_at } )
                  results[parent_place][node][:ranges].last.merge!({ :waiting_to_close => true })
                end

              when "node_down"
                if results[parent_place][node][:ranges].last[:waiting_to_close]
                  results[parent_place][node][:ranges].last.merge!( { :range_end => event.created_at } )
                  results[parent_place][node][:ranges].last[:waiting_to_close] = false
                else
                  results[parent_place][node][:ranges].last[:range_end] = event.created_at
                end
            end

          end
        end
      end
    }

    @titulo = _("Accumulated running time")
    @columnas = [_("Location"), _("Uptime (hrs)"), _("Downtime (hrs)"), _("Up (%)")]
    @fecha_desde = range_start
    @fecha_hasta =  range_end
    @datos = []
    graph_data = []

    hours = 3600
    days = 3600*24
    results.keys.each { |parent_place|

      name = parent_place.getName
      results[parent_place].keys.each { |node|

      if results[parent_place][node][:ranges].last[:waiting_to_close]
        results[parent_place][node][:ranges].last.merge!( { :range_end => range_end } )
      end

      time = 0
      results[parent_place][node][:ranges].each { |range|
        time += range[:range_end] - range[:range_start]
      }

      time_hours = 0
      off_time = 0
      off_time_hours = 0
      if !results[parent_place][node][:changed_type]

        node_type_tag = node.node_type.internal_tag
        if node_type_tag.match("^(server|ap)_down$")
          off_time = time
          off_time_hours = (time/hours).round
        else
          time_hours = (time/hours).round
        end
      else

        time_hours = (time/hours).round
        off_time = (range_end - range_start) - time
        off_time_hours = (off_time/hours).round 
      end

      label = name+"::#{node.name}"
      percent = ((time_hours.to_f/(time_hours+off_time_hours).to_f)*100).round
      @datos.push([label, time_hours, off_time_hours, percent])
      graph_data.push({ :name => label, :value => percent })
      }
    }

    @datos.sort! { |a,b| a[3] < b[3] ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createBar(graph_data, _("Percentages"), { :min => 0, :max => 100 })
    print(params, "online_time_statistics")
  end

  def where_are_these_laptops
    print_params = JSON.parse(params[:print_params]).reverse

    laptop_serials = print_params.pop.split("\n").map { |line| line.strip.upcase }

    laptops = Laptop.includes(:owner, :assignee)
    laptops = laptops.where(:serial_number => laptop_serials)

    @datos = []
    found_laptops = []
    laptops.each { |laptop|
      laptop_serial = laptop.serial_number
      location = ""
      owner = laptop.owner
      assignee = laptop.assignee
      if owner
        location += _("In hands of %s (%s), %s") % [owner.getFullName, owner.getIdDoc, owner.place.getName]
        location += "<br>"
      end
      if assignee
        location += _("Assigned to %s (%s), %s") % [assignee.getFullName, assignee.getIdDoc, assignee.place.getName]
        location += "<br>"
      end

      status_desc = laptop.status.to_s
      @datos.push([laptop_serial, location, status_desc])
      found_laptops.push(laptop_serial)

    }

    #We list all the laptops that where not found in the system
    laptops_not_found = laptop_serials - found_laptops
    laptops_not_found.each { |laptop_serial|
      @datos.push([laptop_serial, "NITS", "NITS"])
    }

    @titulo = _("Where are the laptops?")
    @titulo += "<br><font size=\"1\">" + _("NITS (Not in the system)") + "</font>" if laptops_not_found != []
    @columnas = [_("Laptop"), _("Person and location"), _("Status")]

    print(params, "where_are_these_laptops")
  end

  def used_parts_per_person
    print_params = JSON.parse(params[:print_params]).reverse

    solutions = ProblemSolution.includes({:problem_report => [:place, :owner]}, {:solution_type => :part_types})

    person_type = print_params.pop

    place_type_id = print_params.pop.to_i
    
    place_id = print_params.pop.to_i
    place = Place.find_by_id(place_id)      
    if place
      solutions = solutions.where("problem_reports.place_id in (?)", place.getDescendantsIds.push(place_id))
    else
      raise _("You must select the location")
    end

    part_ids = print_params.pop
    if part_ids != []
      solutions = solutions.where("part_types.id in (?)", part_ids)
    end
    part_types = PartType.where(:id => part_ids)

    results = Hash.new
    solutions.each { |problem_solution|

      if person_type == "solved_by_person"
        person = problem_solution.solved_by_person
      else
        person = problem_solution.problem_report.owner
      end

      place = problem_solution.problem_report.place
      ps_part_types = problem_solution.solution_type.part_types

      parent_place = Place.where(:id => place.getAncestorsIds.push(place.id), :place_type_id => place_type_id).first
    
      if person && parent_place && ps_part_types != []

        results[person] = Hash.new if !results[person]
        if !results[person][parent_place]

          results[person][parent_place] = Hash.new
          part_types.each { |type|
            results[person][parent_place][type] = 0
          }
        end
        
        ps_part_types.each { |part_type|
          results[person][parent_place][part_type] += 1
        }
      end
    }

    @titulo = _("Repair parts used")
    @columnas = [_("Person"), _("Location") ] + part_types.map { |part| part.description } + [_("Total")]
    @datos = []

    results.keys.each { |person|
      person_name = person.getFullName
      results[person].keys.each { |parent_place|
        place_name = parent_place.getName
        total = 0
        row = []
        part_types.each { |type|
          sub_total = results[person][parent_place][type].to_i 
          row.push(sub_total)
          total += sub_total
        }
        row.push(total)
        @datos.push([person_name,place_name]+row)
      }
    }
    sort_key = print_params.pop.to_i
    sort_index = @columnas.length-1
    case sort_key
      when -2
        sort_index = 0
      when -1
        #nothing
      else
        part_type = PartType.where("id = ? and id in (?)", sort_key, part_types.map { |part| part.id }).first
        if part_type
          sort_index = @columnas.index(part_type.description)
        else
          raise _("Can't sort by that part.")
        end
    end

    sort_op_key = print_params.pop
    sort_op = "<"
    sort_op = ">" if sort_op_key == "ASC"

    @datos.sort! { |a,b| a[sort_index].send(sort_op, b[sort_index]) ? 1 : -1 }

    print(params, "used_part_per_person")
  end

  def problems_per_grade
    print_params = JSON.parse(params[:print_params]).reverse

    reports = ProblemReport.includes({:place => :place_type}, :problem_type)
    reports = reports.where("place_types.internal_tag = 'section'")

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "problem_reports.created_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      reports = buildComboBoxQuery(reports, place.getDescendantsIds.push(place_id), "places.id") if place
    else
      raise _("You must select a location.")
    end
 
    problems_type_ids = print_params.pop
    if problems_type_ids != []
      problems_type_titles = ProblemType.find(problems_type_ids).map { |type| type.name }
      reports = buildComboBoxQuery(reports, problems_type_ids, "problem_types.id")
    end

    grade_types = ["first_grade", "second_grade", "third_grade", "fourth_grade", "fifth_grade", "sixth_grade", "seventh_grade", "eighth_grade","ninth_grade"]
    h = Hash.new
    PlaceType.find_all_by_internal_tag(grade_types).each {|type| h[type] = 0 }

    current_year = Date.today.year
    reports.each { |problem_report|
      report_year = problem_report.created_at.year
      rPlace = problem_report.place
      places_ids = rPlace.getAncestorsIds

      grade_place = Place.includes(:place_type)
      grade_place = grade_place.where("places.id in (?) and place_types.internal_tag in (?)", places_ids, grade_types).first

      #Note that we don't want the ACTUAL grade, we need the grade WHEN it happened.
      if grade_place

        current_grade_tag = grade_place.place_type.internal_tag
        the_grade_tag = grade_types[grade_types.index(current_grade_tag) - (current_year - report_year)]
        #raise "#{current_grade_tag} -- #{the_grade_tag}"
      else
    
        the_grade_tag = "special"
      end

        the_grade_type = PlaceType.find_by_internal_tag(the_grade_tag)
        h[the_grade_type] = h[the_grade_type] ? h[the_grade_type]+1 : 1 if the_grade_type
    }

    @titulo = place.getName+"<br>"
    @titulo += _("Problems by grade") + "<br>"
    @titulo += "<font size=\"2\">"+problems_type_titles.join(', ')+"</font><br>"
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @columnas = [_("Grade"), _("Quantity")]
    @datos = []
    graph_data = []

    grade_types.push("special").each { |tag|

      place_type = PlaceType.find_by_internal_tag(tag) 
      @datos.push([place_type.name, h[place_type]])
      graph_data.push({ :name => place_type.name, :value => h[place_type] })
    }
    @datos.sort! { |a,b| a[1].to_i < b[1].to_i ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createBar(graph_data, _("Distribution"))
    print(params, "problems_per_grade")
  end

  def problems_per_school
    print_params = JSON.parse(params[:print_params]).reverse
    reports = ProblemReport.includes({:place => :place_type}, :problem_type)

    timeRange = print_params.pop
    reports = buildDateQuery(reports, timeRange, "problem_reports.created_at")

    place_type_id = print_params.pop.to_i

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      reports = buildComboBoxQuery(reports, place.getDescendantsIds.push(place_id), "places.id") if place
    end

    problems_type_ids = print_params.pop
    if problems_type_ids != []
      problems_type_titles = ProblemType.find(problems_type_ids).map { |type| type.name }
      reports = buildComboBoxQuery(reports, problems_type_ids, "problem_types.id")
    end

    solved_statuses = print_params.pop
    if solved_statuses != []
      reports = reports.where(:solved => solved_statuses)
    end

    sort_criteria = print_params.pop.to_i

    h = Hash.new
    reports.each { |problem_report|

      places_ids = problem_report.place.getAncestorsIds

      place = Place.includes(:place_type).where(:id => places_ids)
      place = place.where("place_types.id = ?", place_type_id).first

      if place
        if !h[place]
          h[place] = Hash.new
          h[place][true] = 0
          h[place][false] = 0
        end
        h[place][problem_report.solved]+= 1
      end
    }

    @titulo = _("Problems by location") + "<br>"
    @titulo += "<font size=\"2\">"+problems_type_titles.join(', ')+"</font>"
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @columnas = [_("Location"), _("Solved"), _("Not solved"), _("Absolute total"), _("People"), _("Per person"), _("Eficiency (%)")]
    @datos = []
    graph_data = []

    h.keys.each { |place|
      name = place.getName
      name += " (#{place.description})" if !place.description.nil?

      total_people = place.performing_people.length
      solved_problems = h[place][true]
      unsolved_problems = h[place][false]
      total_problems = solved_problems + unsolved_problems
      problems_per_people = "%4.1f" % (total_problems.to_f/total_people.to_f)
      technician_eff = "%4.1f" % ((solved_problems.to_f/total_problems.to_f)* 100.to_f)

      @datos.push([ name, h[place][true], h[place][false], total_problems, total_people, problems_per_people, technician_eff] )
      graph_data.push({ :name => name, :value => total_problems })
    }
    @datos.sort! { |a,b| a[sort_criteria].to_f < b[sort_criteria].to_f ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createPie(graph_data,_("Distribution (absolute)"))
    print(params, "problems_per_place")
  end

  def registered_laptops
    print_params = JSON.parse(params[:print_params]).reverse
 
    root_place_id = print_params.pop.to_i
    filters = print_params.pop

    @title = _("Status of registered laptops")
    @hashes_array = Array.new
    @columns = [_("Owner"), _("Document id"), _("Serial number"), _("Registered")]

    root_place = Place.find_by_id(root_place_id)

    places = [root_place]
    while(places != [])

      place = places.pop
      people = place.people
      if people != []

      place_hash = Hash.new
      place_hash[:sub_title] = place.getName
      place_hash[:sub_array] = Array.new
      people.each { |person|
   
        laptops = person.laptops
        if laptops != []

           person_name = person.getFullName
           laptops.each { |laptop|
      
             if filters.include?(laptop.registered)
               place_hash[:sub_array].push([person_name, person.id_document, person.profile.description, laptop.serial_number, laptop.getRegistered])
             end
           }
        end
      }

      @hashes_array.push(place_hash)
      end

      places += place.places.reverse  

    end

    print(params, "registered_laptops_status", "print/hashes_array")
  end

  def printable_delivery
    print_params = JSON.parse(params[:print_params]).reverse
    mov_ids = print_params.pop.map {| pair| pair["value"].to_i }
 
    @title = _("Delivery receipt")
    @data = Array.new
  
    movements = Movement.includes(:laptop, :destination_person)
    movements = movements.where(:id => mov_ids)
    movements.each {|movement|
      h = Hash.new
      h[:id] = movement.id
      h[:parts] = [{ :part => "Laptop",
                     :serial => movement.laptop.serial_number }]
      h[:person] = movement.destination_person.to_s
      @data.push(h)
    }

    print(params, "printable_delivery", "print/printable_delivery")
  end

  def people_laptops
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    root_place = Place.find_by_id(place_id)

    include_filter = print_params.pop

    if params[:print_format] == "xls"
      people_laptops_xls root_place, include_filter
      return
    end

    @titulo = _("People of %s and their laptops") % root_place.getName
    @columnas = ["#", _("Name"), _("Document id"), _("Laptop"), _("In hands")]
    @datos = []

    stack = [root_place]
    while(stack != [])
      place = stack.pop
      stack+= place.places.reverse

      performs = Perform.where(:place_id => place.id)
      performs = performs.includes({ :person => { :laptops_assigned => :status } })
      performs = performs.order("people.lastname, people.name")
      if include_filter == "only_people_with_laptops"
        performs = performs.where("laptops.id IS NOT NULL")
      elsif include_filter == "only_people_without_laptops"
        performs = performs.where("laptops.id IS NULL")
      end
      next if performs.count == 0

      entries = []
      performs.each { |perform|
        person = perform.person
        laptops = person.laptops_assigned
        first = true
        if laptops.length == 0
          entries.push({:type => "person_no_laptop", :name => person.getFullName(), :doc_id => person.id_document})
        end
        laptops.each { |laptop|
          delivered = laptop.assignee == laptop.owner
          status = (laptop.status.internal_tag != "activated") ? laptop.status.to_s : nil
          if first
            entries.push({:type => "person", :name => person.getFullName(), :doc_id => person.id_document, :laptop_sn => laptop.serial_number, :status => status, :delivered => delivered})
          else
            entries.push({:type => "multiple", :laptop_sn => laptop.serial_number, :status => status, :delivered => delivered})
          end
          first = false
        }
        if person.notes and person.notes != ''
          entries.push({:type => "person_notes", :notes => person.notes})
        end

      }

      @datos.push({:name => place.getName, :data => entries})
    end
    print(params, "people_laptops", "print/people_laptops")
  end

  def people_laptops_xls(root_place, include_filter)
    workbook = Spreadsheet::Workbook.new

    stack = [root_place]
    while(stack != [])
      place = stack.pop
      stack+= place.places.reverse

      performs = Perform.where(:place_id => place.id)
      performs = performs.includes({ :person => { :laptops_assigned => :status } })
      performs = performs.order("people.lastname, people.name")
      if include_filter == "only_people_with_laptops"
        performs = performs.where("laptops.id IS NOT NULL")
      elsif include_filter == "only_people_without_laptops"
        performs = performs.where("laptops.id IS NULL")
      end
      next if performs.count == 0

      worksheet = workbook.create_worksheet()
      worksheet[0, 0] = place.getName
      worksheet.row(1).push("#", _("Name"), _("Document id"), _("Laptop"), _("Laptop status"), _("In hands"), _("Notes"))

      row_num = 1
      cnt = 0
      performs.each { |perform|
        cnt = cnt + 1
        row_num = row_num + 1
        row = worksheet.row(row_num)
        person = perform.person
        laptops = person.laptops_assigned

        row.push(cnt)
        row.push(person.getFullName)
        row.push(person.id_document)

        if person.notes and person.notes != ''
          row[6] = person.notes
        end

        if laptops.length == 0
          row[3] = _("None")
        end
        first = true
        laptops.each { |laptop|
          row_num = row_num + 1 if !first
          row = worksheet.row(row_num)

          if laptop.assignee == laptop.owner
            delivered = _("Yes")
          else
            delivered = _("No")
          end
          status = (laptop.status.internal_tag != "activated") ? laptop.status.to_s : nil
          row[3] = laptop.serial_number
          row[4] = status
          row[5] = delivered

          row[6] = _("Person has multiple laptops!") if !first
          first = false
        }
      }
    end

    file_name = Rails.root.join("/tmp/", Kernel.rand.to_s.split(".")[1] + ".xls").to_s
    workbook.write file_name
    send_file(file_name,:filename => "people_laptops.xls",:type => "application/vnd.ms-excel",:stream => false )
  end

  def people_documents
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    place = Place.find_by_id(place_id)
    raise _("Invalid Place") if not place

    document_filters = print_params.pop

    people = Person.includes(:performs)
    people = people.where("id_document not REGEXP \"_\"") if not document_filters.include?('fake')
    people = people.where("id_document REGEXP \"_\"") if not document_filters.include?('normal')

    columns = [_("Location"), _("Name"), _("Document id")]
    rows = []
    student_id = Profile.find_by_internal_tag('student').id
    people = people.where("performs.profile_id" => student_id)

    places = [place]
    while(places != [])
        place = places.pop
        location = place.getName()
        people.where("performs.place_id" => place.id).each { |person|
            rows.push([location, person.getFullName, person.getIdDoc])
        }

        places += place.places.reverse
    end

    file_name = FormatManager.generarExcel2(rows,columns)
    send_file(file_name,:filename => "id_documents.xls",:type => "application/vnd.ms-excel",:stream => false )
  end

  def laptops_uuids
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    root_place = Place.find(place_id)

    relate = { "assignment" => "assignee_id", "physical" => "owner_id" }
    criteria = print_params.pop
    raise _("Invalid Criteria") if relate[criteria].nil?
    relation = relate[criteria]

    include_people = print_params.pop
    raise _("Invalid filter") if include_people.nil?

    buffer = ""

    places_ids = root_place.getDescendantsIds + [root_place.id]
    people_ids = Perform
    if include_people == "only_teachers"
      people_ids = people_ids.includes(:profile)
      people_ids = people_ids.where("profiles.internal_tag" => "teacher")
    elsif include_people == "only_students"
      people_ids = people_ids.includes(:profile)
      people_ids = people_ids.where("profiles.internal_tag" => "student")
    end
    people_ids = people_ids.find_all_by_place_id(places_ids)
    people_ids = people_ids.collect(&:person_id)

    laptops = Laptop.includes(:status)
    laptops = laptops.where("serial_number is not NULL and serial_number != \"\"")
    laptops = laptops.where("uuid is not NULL and uuid != \"\"")
    laptops = laptops.where("status_id is not NULL and statuses.internal_tag = \"activated\"")
    laptops = laptops.where("status_id is not NULL")
    laptops = laptops.where("statuses.internal_tag" => ["activated", "on_repair", "repaired"])
    laptops = laptops.where("#{relation} in (?)", people_ids)

    laptops.each { |laptop|
      buffer +=  "#{laptop.serial_number.to_s},#{laptop.uuid.to_s}\n"
    }

    send_data buffer, :type => 'text/plain', :filename => 'laptops.txt'
  end

  def possible_mistakes
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    root_place = Place.find_by_id(place_id)

    @titulo = _("Possible errors during deliery in %s") % root_place.getName
    @columnas = [_("Name"), _("Document id"), _("Laptop"), _("Has laptop?")]
    @datos = []

    total = 0
    total_con_laptops = 0
    student_profile_id = Profile.find_by_internal_tag("student").id
    section_place_type_id = PlaceType.find_by_internal_tag("section").id

    performs = Perform.includes(:person => :laptops).where(:profile_id => student_profile_id)

    stack = [root_place]
    while(stack != [])
      place = stack.pop

      if place && place.place_type && place.place_type.internal_tag == "section"
        sub_total = 0
        sub_total_con_laptops = 0

        performs.where(:place_id => place.id).each { |perform|
          person = perform.person

          possible_clones = Person.where(:name => person.name)
          possible_clones.where("id != ?", person.id).each { |possible_clone|

            check = Perform.find_by_person_id_and_place_id_and_profile_id(possible_clone.id, place.id, student_profile_id)
            if check
              sub_total+=1
              total+= 1

              laptops = possible_clone.laptops
              if laptops == []
                laptop_str = _("No")
                laptops_srl = ""
              else
                total_con_laptops+=1
                sub_total_con_laptops+=1
                laptop_str = _("Yes")
                laptops_srl = laptops.first.serial_number
              end
              @datos.push([possible_clone.name, possible_clone.id_document,laptops_srl,laptop_str])
            end
          }
        }

        if sub_total > 0
          str_vars = [ place.getName, sub_total.to_s, sub_total_con_laptops.to_s, (sub_total-sub_total_con_laptops).to_s]
          sub_print_str = _("<b>(%s):</b> There is %s repeated, of which %s have laptops y %s don't.") % str_vars
          @datos.push([sub_print_str,"","",""])
          @datos.push(["","","",""])
        end

      end
      stack+= place.places.reverse
    end

    if total > 0
      str_vars = [total.to_s, total_con_laptops.to_s, (total-total_con_laptops).to_s]
      print_str = _("<B>In total:</B> there is %s repeated students, of which %s have laptos and %s don't.") % str_vars
    else
      print_str = _("No possible errors found.")
    end
    @datos.push([print_str,"","",""])

    print(params, "possible_mistakes")
  end

  def laptops_per_tree
    print_params = JSON.parse(params[:print_params]).reverse
    graph_data = []

    place_id = print_params.pop
    place = Place.find_by_id(place_id)

    @titulo = "Laptops distributions at %s " % place.getName
    @columnas = [_("School num."), _("School name"), _("Quantity")]
    @datos = []
    @grand_total = 0
    place.places.each { |subPlace|
      sub_total = 0
      sub_places_ids = subPlace.getDescendantsIds
      Place.find_all_by_id(sub_places_ids).each { |subSubPlace|
        subSubPlace.performs.each { |perform|
          sub_total += perform.person.laptops.length
        }
      }

      name = subPlace.name
      name_str = subPlace.place_type.name + " " + name + " - " + subPlace.description
      h = { :name => name_str, :value => sub_total }
      @datos.push([name_str, subPlace.description, sub_total])
      @grand_total += sub_total
      graph_data.push(h)
    }

    # order by total descending
    @datos.sort! { |a,b| a[2] < b[2] ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createPie(graph_data,@titulo)
    print(params, "laptops_per_tree")
  end

  def lots_labels
    print_params = JSON.parse(params[:print_params]).reverse

    lot = Lot.find_by_id(print_params.pop)

    @labels = Array.new
    @times = Array.new
    @total = lot.boxes_number
    @math_total = 0
    @responsable = lot.person.getFullName
    lot.section_details.each { |section_detail|
      @labels.push(section_detail.place.getName)
      laptops_num = section_detail.laptop_details.length
      sub_total = laptops_num%5==0 ? (laptops_num/5) : ((laptops_num/5)+1)
      @times.push(sub_total)
      @math_total += sub_total
    }

    print(params, "lotes", "print/lots_labels")
  end

  def barcodes
    max_place_length = 45
    max_name_length = 26
    print_params = JSON.parse(params[:print_params])
    filters = print_params["laptop_filter"]

    root_places = []
    places = Place.find_all_by_id(print_params["places"])
    places.each { |root|
      isRoot = true
      places.each { |place|
        isRoot = false if root != place && place.getDescendantsIds.include?(root.id)
      }
   
      root_places.push(root) if isRoot
    }

    @box_labels = print_params["box_labels"]
    @laptop_name_labels = !print_params["laptop_names"].nil?
    @num_of_cols = 3
    @data = Array.new
    root_places.each { |root_place|

      stack = [root_place]
      while(stack != [])
        current_place = stack.pop

        place_info = Hash.new
        fixed_place_name = current_place.getName

        if fixed_place_name.length > max_place_length
          fixed_place_name = "..." + fixed_place_name.mb_chars[-max_place_length..-1].to_s
        end
        place_info[:title] = fixed_place_name

        students = Array.new

        performs = Perform.includes({:person => :laptops}, :place, :profile)
        performs = performs.where(:place_id => current_place.id)
        performs = performs.where('profiles.internal_tag' => print_params["profile_filter"])
        performs.order("people.lastname, people.name").each { |perform|
          person = perform.person
          laptops = person.laptops
          laptops_assigned = person.laptops_assigned
          print_barcode = ((filters.include?("with") and laptops != []) or
                           (filters.include?("without") and laptops == []) or
                           (filters.include?("with_assigned") and laptops_assigned != []) or
                           (filters.include?("without_assigned") and laptops_assigned == []))
          if print_barcode
            student = Hash.new
            fixed_person_name = person.getFullName
            if fixed_person_name.length > max_name_length
              fixed_person_name = fixed_person_name.mb_chars[0..max_name_length].to_s + "..."
            end

            student[:full_name] = person.getFullName
            student[:name] = fixed_person_name
            student[:place] = fixed_place_name
            student[:barcode] = person.getBarcode
            students.push(student)
          end
        }

        place_info[:boxes] = Array.new

        # If the overpack option is enabled, we try to avoid having the last
        # box with only 1 or 2 laptops by packing those last laptops into
        # earlier boxes (meaning that some boxes will have 6 laptops).
        #
        # 7 laptops is a special case, as we would have 2 left over we would
        # try to overpack 2 boxes, but as we are only dealing with 2 boxes
        # either way it doesn't make sense: we should fall back and accept
        # one box of 5 and one box of 2 (rather than 6+1).
        if APP_CONFIG["overpack_boxes"] and students.length != 7
          overpack_boxes = students.length % 5
          overpack_boxes = 0 if overpack_boxes > 2
        else
          overpack_boxes = 0
        end

        i = 0
        while students[i] do
          to_pack = 5
          if overpack_boxes > 0
            overpack_boxes -= 1
            to_pack += 1
          end

          place_info[:boxes].push(students[i, to_pack])
          i += to_pack
        end

        @data.push(place_info)
        stack+= current_place.places.reverse
      end
    }

    print(params, "codigos-usuarios", "print/barcodes")
  end

  ####
  # Movements.
  #
  def movements
    print_params = JSON.parse(params[:print_params]).reverse
    movements = Movement.includes(:laptop,:movement_type,:source_person, {:destination_person => {:performs => :place}})

    dateOpts = print_params.pop
    movements = buildDateQuery(movements, dateOpts, "movements.date_moved_at")

    serials = print_params.pop
    movements = buildSerialQuery(movements,serials)

    reasons = print_params.pop
    movements = buildReasonQuery(movements,reasons,"movements")

    from_person_id = print_params.pop
    movements = buildPersonQuery(movements, from_person_id,"movements.source_person_id")

    to_person_id = print_params.pop
    movements = buildPersonQuery(movements, to_person_id,"movements.destination_person_id")

    place_id = print_params.pop
    if place_id.to_i != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      movements = buildComboBoxQuery(movements, places, "places.id")
    end

    @titulo = _("Laptop movements")
    @fecha_desde = dateOpts["date_since"]
    @fecha_hasta = dateOpts["date_to"]
    @columnas = [_("Mov \#"), _("Fecha"), _("Serial"), _("Given by"), _("Received by"), _("Reason")]
    @datos = []

    movements.order("movements.id ASC").each  { |m|
      @datos.push([m.id,
                   m.date_moved_at,
                   m.laptop.serial_number,
                   m.source_person.to_s,
                   m.destination_person.to_s,
                   m.movement_type.to_s])
    }

    print(params, "movements")
  end

  ###
  # Movement types (totals).
  #
  def movement_types
    print_params = JSON.parse(params[:print_params]).reverse
    types = MovementType.includes(:movements => [ {:destination_person => :performs}, :laptop ])

    from_person_id = print_params.pop
    types = buildPersonQuery(types, from_person_id, "movements.source_person_id")

    to_person_id = print_params.pop
    types = buildPersonQuery(types, to_person_id, "movements.destination_person_id")

    dateOpts = print_params.pop
    types = buildDateQuery(types, dateOpts, "movements.date_moved_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      types = buildComboBoxQuery(types, places, "performs.place_id")
    else
      raise _("You must select a location.")
    end

    @titulo = _("Totals by movement type")
    @fecha_desde = dateOpts["date_since"]
    @fecha_hasta = dateOpts["date_to"]
    @columnas = [_("Type")]
    @columnas.push(_("Laptops"))
    @datos = []

    graph_data = Array.new
    types.each { |mt|
      total=laptops=0
      mt.movements.each { |m| laptops += 1 }

    h = { :name => mt.description, :value => laptops } 
    graph_data.push(h)

    v = []
    v.push(mt.description)
    v.push(laptops)
    @datos.push(v)
    }

    @image_name = "/" + PyEducaGraph::createPie(graph_data,@titulo)

    print(params, "movement_types")
  end

  ##
  # Movimientos en un vetana de tiempo.
  def movements_time_range
    print_params = JSON.parse(params[:print_params]).reverse
    movements = Movement.includes({:destination_person => {:performs => :place}}, :source_person, :laptop)

    dateOpts = print_params.pop
    movements = buildDateQuery(movements, dateOpts, "date_moved_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      movements = buildComboBoxQuery(movements, places, "places.id")
    end

    # Se definen los elementos del view.
    @titulo = _("Movements on a given timeframe")
    @fecha_desde = dateOpts["date_since"]
    @fecha_hasta = dateOpts["date_to"]
    @columnas = [_("\#"), _("Date"), _("Laptop"), _("Responsible"), _("Delivered by"), _("Received by")]
    @datos = movements.map { |d|
      a = Array.new
      a.push(d.id)
      a.push(d.date_moved_at)
      a.push(d.laptop.serial_number)
      a.push(d.creator.to_s)
      a.push(d.source_person.to_s)
      a.push(d.destination_person.to_s)
      a
    }
    print(params, "movements")
  end

  ##
  # Distribution of laptops owned per person. 
  def laptops_per_owner

    print_params = JSON.parse(params[:print_params]).reverse
    people = Person.includes(:laptops)

    ownerData = print_params.pop
    people = buildPersonQuery(people, ownerData, "id")

    @datos = []
    laptops.each { |p|
      if p.laptops.length > 0
        @datos.push([p.getFullName(),p.laptops.length])
      end
    }

    # order according number of laptops (descending)
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    @titulo = _("Laptops per owner")
    @columnas = [_("Person"), _("Quantity")]
    print(params, "laptops")
  end

  ##
  # Distribution of laptops handed off per person. 
  def laptops_per_source_person
    print_params = JSON.parse(params[:print_params]).reverse
    people = Person.includes(:source_movements)

    source_person = print_params.pop
    people = buildPersonQuery(people,source_person,"id")

    @titulo = _("Laptops handed out per person")
    @columnas = [_("Person"), _("Quantity")]
    @datos = []
    people.each { |p|
      count=0
      p.source_movements.each { |m| count+=1 }
      @datos.push([p.getFullName(),count]) if count != 0
    }

    # Sort by count in descending order
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    print(params, "laptops")
  end

  ##
  # God (Dijkstra) forgive me. 
  #
  # FIXME: this almost an *exact* copy of the above method. Refactoring?
  #
  # Distribution of laptops to people.
  def laptops_per_destination_person
    print_params = JSON.parse(params[:print_params]).reverse
    people = Person.includes(:destination_movements)

    destination_person = print_params.pop
    people = buildPersonQuery(people,destination_person,"id")

    @titulo = _("Laptops given to people")
    @columnas = [_("Person"), _("Quantity")]
    @datos = []
    people.each { |p|
      count=0
      p.destination_movements.each { |m| count+=1 }
      @datos.push([p.getFullName(),count]) if count != 0
    }

    # Sort by count in descending order
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    print(params, "laptops")
  end
 
  ##
  # Laptops lended. 
  #
  def lendings
    print_params = JSON.parse(params[:print_params]).reverse
    movements = Movements.where("return_date is not null")

    timeRange = print_params.pop
    movements = buildDateQuery(movements,timeRange,"date_moved_at")

    sourcePerson = print_params.pop
    movements = buildPersonQuery(movements,sourcePerson,"source_person_id")

    destinationPerson = print_params.pop
    movements = buildPersonQuery(movements,destinationPerson,"destination_person_id")

    filters = print_params.pop
    if filters.length > 0
      movements = movements.where(returned: false) if !filters.include? "returned"
      movements = movements.where(returned: true) if !filters.include? "not_returned"
    end

    @titulo = _("Lendings")
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta = timeRange["date_to"]
    @columnas = [_("#"), _("Date"), _("Given by"), _("Received by"), _("Return date"), _("Serial number"), _("Returned?")]
    @datos =[]
    counter = 1
    movements.order("date_moved_at DESC").each { |m|
        @datos.push([counter,
                     m.date_moved_at,
                     m.source_person.to_s,
                     m.destination_person.to_s,
                     m.return_date.to_s,
                     m.serial_number,
                     m.returned ? _("Yes") : _("No")
                    ])
        counter+=1
    }

    print(params, "prestamos")
  end

  ###
  # Laptops grouped by status. 
  #
  def statuses_distribution
    print_params = JSON.parse(params[:print_params]).reverse
    statuses = Status.includes(:laptops => {:owner => :performs})

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      statuses = buildComboBoxQuery(statuses, places_ids, "performs.place_id")
    end

    @titulo = _("Distribution of laptops grouped by status")
    @columnas = [_("Status"), _("Quantity")]
    @datos = []

    graph_data = Array.new

    statuses.each { |s|
      v = []

      v.push(s.description)
      v.push(s.laptops.length)
      @datos.push(v)

      # save for graphing
      total = 0
      v[1..10].each { |i| total += i }
      h = { :name => s.description, :value => total } 
      graph_data.push(h)
    }

    # TODO: this should be conditional
    @image_name = "/" + PyEducaGraph::createPie(graph_data, @titulo)
 
    print(params, "statuses_distribution")
  end

  ###
  # Changes of status. 
  #
  def status_changes
    print_params = JSON.parse(params[:print_params]).reverse
    changes = StatusChange.includes(:previous_state, :new_state, :laptop)

    timeRange = print_params.pop
    changes = buildDateQuery(changes,timeRange,"status_changes.date_created_at")

    @titulo = _("Status changes")
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta = timeRange["date_to"]
    @columnas = [_("Date"), _("Previous"), _("Next"), _("Serial Number")]
    @datos = []

    changes.order("status_changes.date_created_at DESC").each {  |sc|
      @datos.push([sc.getDate(),sc.getPreviousState(),sc.getNewState(),sc.getPart(),sc.getSerial()])
    }

    print(params, "cambios_de_estado")
  end

  ###
  # Laptops grouped by their location. 
  #
  def laptops_per_place
    print_params = JSON.parse(params[:print_params]).reverse
    place_id = print_params.pop

    p = Place.find_by_id(place_id)
    root = p.getPartDistribution()
    @matrix = p.buildMatrix(root, Array.new, 0, p.getTreeDepth(root))
    @title = _("Number of laptops per location")
    @comment = _("The penultimate column shows the number of laptops physically in the place (or in a sub-place).<br>The final column shows the number of laptops assigned to that place (or a sub-place).")
    @date = Fecha.getFecha()

    print(params, "laptops_por_tipo_localidad", "print/laptops_per_place_type")
  end

  ###
  # Parts replaced. 
  #
  def parts_replaced
    print_params = JSON.parse(params[:print_params]).reverse
    solutions = ProblemSolution.includes({:problem_report => :place}, {:solution_type => :part_types})

    timeRange = print_params.pop
    solutions = buildDateQuery(solutions,timeRange,"problem_solutions.created_at")

    group_criteria = print_params.pop
    if ["day","week","month","year"].include?(group_criteria)
      group_method = "beginning_of_"+group_criteria
    else
      raise _("Not allowed")
    end

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      solutions = buildComboBoxQuery(solutions, place.getDescendantsIds.push(place_id), "places.id") if place
    end

    part_type_ids = print_params.pop
    if part_type_ids != []
      part_types = PartType.find_all_by_id(part_type_ids)
      solutions = buildComboBoxQuery(solutions, part_type_ids, "part_types.id")
    end

    since = timeRange["date_since"].to_date.send(group_method)
    to = timeRange["date_to"].to_date.send(group_method)

    results = Hash.new
    aux_window = since.dup
    while (aux_window <= to)
      results[aux_window] = Hash.new
      part_types.each { |part_type| results[aux_window][part_type] = 0 }
      aux_window += 1.send(group_criteria)
    end

    solutions.each { |ps|
      ps_part_types = ps.solution_type.part_types
      if ps_part_types != []

        window = ps.created_at.send(group_method)
        ps_part_types.each { |part_type| 
          results[window][part_type] += 1
        }
      end
    }

    @titulo = _("Used repair parts")
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @columnas = [_("Part"), group_criteria.camelize, _("Quantity")]
    @datos = []
    graph_data = []
    graph_labels = {}

    # TODO: Optimize me, oh godddddd....
    swapped_results = {}
    part_types.each { |part_type| swapped_results[part_type] = {} }
    ordered_results = results.keys.sort { |a,b| a <= b ?  -1  : 1 }

    # Swapping elements and creating labels for the line graph
    ordered_results.each_with_index { |window, index|
      results[window].keys.each { |type| swapped_results[type][window] = results[window][type] }
      graph_labels[index] = Fecha.pyDate(window.to_date)
    }

    # generating data for the report and graph
    swapped_results.keys.each { |type|

      name = type.description
      value = []

      @datos.push([name, "", ""])
      ordered_results.each { |window|
        amount = swapped_results[type][window].to_i
        @datos.push(["", Fecha.pyDate(window.to_date), amount])
        value.push(amount)
      }
      graph_data.push({ :name => type.description, :value => value })
    }

    @image_name = "/" + PyEducaGraph::createLine(graph_data, _("Timeline"), graph_labels)
    print(params, "repuestos_utilizados")
  end

  def problems_per_type
    print_params = JSON.parse(params[:print_params]).reverse
    types = ProblemType.includes({:problem_reports => [{:laptop => :owner}, :place]})

    timeRange = print_params.pop
    types = buildDateQuery(types,timeRange,"problem_reports.created_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      subplaces_ids = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      types = buildComboBoxQuery(types,subplaces_ids,"places.id")
    end

    problem_types = print_params.pop
    types = buildComboBoxQuery(types,problem_types,"problem_types.id")

    @titulo = _("Problems grouped by type") 
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @columnas = [_("Type"), _("Quantity")]
    @datos = []

    graph_data = Array.new
    types.each { |pt|
      desc = pt.name
      amount = pt.problem_reports.length
      @datos.push([desc, amount])
      graph_data.push({ :name => desc, :value => amount })
    }
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    @image_name = "/" + PyEducaGraph::createPie(graph_data, _("Distribution"))
    print(params, "problemas_por_tipo")
  end

  def laptops_check
    xls_rows = []
    xls_columns = [_("Serial Number"), _("Owner"), _("Document id"), _("Location")]
    global_repeated = []

    # super speed hack
    results = ActiveRecord::Base.connection.execute("SELECT serial_number,
                                                     COUNT(serial_number) AS repeated 
                                                     FROM laptops
                                                     GROUP BY serial_number
                                                     HAVING repeated > 1;")
    results.each { |row|
      serial_number = row[0]
      laptops = Laptop.includes(:owner => {:performs => :place})
      laptops.find_all_by_serial_number(serial_number).each { |laptop|
        owner = laptop.owner
        location = owner.performs.first.place
        xls_rows.push([serial_number, owner.getFullName, owner.getIdDoc, location.getName])
      }
    }

    file_name = FormatManager.generarExcel2(xls_rows, xls_columns)
    send_file(file_name,:filename => "laptops_check.xls",:type => "application/vnd.ms-excel",:stream => false )
  end

  private

  def print(params, filename, template = "print/report", options = {})
    fmt = params[:print_format]
    if fmt == "pdf"
      print_pdf(filename, template, options)
    else
      render :template => template, :layout => false
    end
  end

  ###
  # Generate the PDF
  #
  #  options(Hash):
  #   :margen_superior
  #   :margen_inferior
  #   :margen_izquierdo
  #   :margen_derecho
  #
  def print_pdf(filename, template, options = Hash.new)
    # necessary for RoR >= 2.1.x
    begin 
     add_variables_to_assigns
    rescue
    end

    htmldoc_env = "HTMLDOC_NOCGI=TRUE;export HTMLDOC_NOCGI"   # Por no se que raye que tiene el htmldoc

    # Letras disponibles {courier,helvetica,monospace,sans,serif,times}
    margen_superior = "0cm"
    margen_inferior = "1cm"
    margen_izquierdo = "0.5cm"
    margen_derecho = "0.5cm"
    letra = "sans"

    footer_str = "..."
    if options.length > 0
      margen_superior = options[:margen_superior] if options[:margen_superior]
      margen_inferior = options[:margen_inferior] if options[:margen_inferior]
      margen_izquierdo = options[:margen_izquierdo] if options[:margen_izquierdo]
      margen_derecho = options[:margen_derecho] if options[:margen_derecho]
      letra = options[:letra] if options[:letra]
      if options[:mostrar_nro_pagina]
        footer_str = "1.."
      else
        footer_str = "..."
      end
    end
    
    open_arg = "#{htmldoc_env}; iconv -f UTF-8 -t iso-8859-1 | htmldoc --header ... --footer #{footer_str} "
    open_arg += "--charset iso-8859-1 "
    open_arg += "--left #{margen_izquierdo} --right #{margen_derecho} --top #{margen_superior} "
    open_arg += "--bottom #{margen_inferior} --bodyfont #{letra} --textfont #{letra} "
    open_arg += "-t pdf --path \".;http://#{request.env["HTTP_HOST"]}\" --webpage -"

    begin
      generator = IO.popen(open_arg, "w+")
      # FIXME: we should test if we are in Windows and included the following method call
      # generator.binmode
      generator.puts render_to_string(:template => template, :layout => false)
      generator.close_write

      send_data(generator.read, :filename => filename + ".pdf", :type => "application/pdf") 
    rescue
      logger.error("error!!!!!!!!" + $!)
    end
  end

  def  htmlEmptyLines(rowCnt,colCnt)
    ret = Array.new
    celda_vacia = "&nbsp;"
    rowCnt.times do
      f = Array.new
      colCnt.times do
        f.push(celda_vacia)
      end
      ret.push(f)
    end
    ret
  end


  def buildDateQuery(query, dateOpts, col_canonical_name)
    if dateOpts["date_since"] && dateOpts["date_since"].to_s != ""
      query = query.where("#{col_canonical_name} >= ? ", Fecha::usDate(dateOpts["date_since"]))
    end

    if dateOpts["date_to"] && dateOpts["date_to"].to_s != ""
      query = query.where("#{col_canonical_name} <= ? ", Fecha::usDate(dateOpts["date_to"]))
    end

    query
  end

  def buildPartQuery(query, partOpts, table_name)
    if partOpts.length > 0 && partOpts.length != 3
      if !partOpts.include? "laptop"
        query = query.where("#{table_name}.laptop_id is null") 
      end
    end
    query
  end

  def buildPersonQuery(query, person_id, col_canonical_name)
    if person_id.to_i != -1
      query = query.where("#{col_canonical_name} = ?", person_id)
    end
    query
  end

  def buildReasonQuery(query,reasons,col_canonical_name)
    if reasons && reasons.length > 0
      query = query.where("#{col_canonical_name}.movement_type_id in (?)", reasons)
    end
    query
  end

  def buildComboBoxQuery(query, cb_options, col_canonical_name)
    if cb_options && cb_options.length > 0
      query = query.where("#{col_canonical_name} in (?)", cb_options)
    end
    query
  end

  def buildSerialQuery(query, cvs_fields)
    if cvs_fields.length > 0
      theres_one = false
      cond_aux = " ( "
      cond_params = []
      for field in cvs_fields do
        if field["value"] && field["value"] != ""
          theres_one = true
          cond_aux += " or " if cond_aux != " ( "
          cond_aux += "#{field["col_name"].pluralize}.serial_number = ?"
          cond_params.push(field["value"])
        end
      end
      cond_aux += " ) "
      if theres_one
        query = query.where(cond_aux, *cond_params)
      end
    end
    query
  end

end
