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
        @datos.push(["", "", owner.getFullName, owner.getIdDoc, laptop.getSerialNumber])
      }
    }

    imprimir("lot_information", "print/" + "report")
  end

  def stock_status_report
    print_params = JSON.parse(params[:print_params]).reverse
    cond = [""]
    inc = [:place, :part_type, :part_movement_type]

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "part_movements.place_id")     
    end

    stock_status = {}

    PartType.all.each { |part_type|
      stock_status[part_type] = { true => 0, false => 0 }
    }

    PartMovement.find(:all, :conditions => cond, :include => inc).each { |part_movement|

      stock_status[part_movement.part_type][part_movement.part_movement_type.direction] += part_movement.amount
    }

    @titulo = _("Estado del stock en %s") % root_place.getName
    @columnas = [_("Part"), _("Incoming"), _("Outgoing"), _("Difference")]
    @datos = []
    
    stock_status.keys.each { |part_type|
      values = stock_status[part_type]
      @datos.push([part_type.getDescription, values[true], values[false], values[true]-values[false]])
    }

    imprimir("stock_status_report", "print/" + "report")
  end

  def audit_report
    print_params = JSON.parse(params[:print_params]).reverse
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "audits.created_at")

    auditable_type = print_params.pop
    cond[0] += " and audits.auditable_type = ?"
    cond.push(auditable_type)

    @titulo = _("Audit at %s") % auditable_type
    @columnas = [_("Date"), _("User"), _("Id"), _("Column"), _("Before"), _("After")]
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @datos = []

    Audit.find(:all, :conditions => cond, :order => "audits.created_at ASC").each { |audit_row|
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

    imprimir("Audit_report", "print/" + "report")
  end

  def average_solved_time

    print_params = JSON.parse(params[:print_params]).reverse    
    inc = []
    cond = ["problem_reports.solved_at is not NULL"]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "problem_reports.created_at")  

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")     
    end

    time_min = false
    time_max = false
    time_acum = 0
    time_count = 0
    ProblemReport.find(:all, :conditions => cond, :include => inc).each { |report|

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

    imprimir(_("Average time"), "print/" + "report")
  end

  def laptops_problems_recurrence

    print_params = JSON.parse(params[:print_params]).reverse    
    inc = [:laptops => :problem_reports]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "problem_reports.created_at")  

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")     
    end

    results = [0,0,0,0,0]
    results.each_index { |index|
      Person.find(:all, :conditions => cond, :include => inc).each { |person|
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
    imprimir(_("Recurrence problems"), "print/" + "report")
  end

  def is_hardware_dist
    print_params = JSON.parse(params[:print_params]).reverse    
    inc = [:problem_type]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "problem_reports.created_at")  

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")     
    end

		solved = print_params.pop
		cond[0] += " and problem_reports.solved in (?)"
		cond.push(solved)

    results = { true => 0, false => 0 }
    ProblemReport.find(:all, :conditions => cond, :include => inc).each { |report|

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
    imprimir("distribution_hardware_software", "print/" + "report")
  end

  def problems_time_distribution

    print_params = JSON.parse(params[:print_params]).reverse    
    inc = [:problem_type, {:laptop => :model}]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "problem_reports.created_at")   

    window_size = print_params.pop

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")     
    end

    problem_types_ids = print_params.pop
    buildComboBoxQuery(cond, problem_types_ids, "problem_types.id")

    laptops_models_ids = print_params.pop
    buildComboBoxQuery(cond, laptops_models_ids, "models.id")
    laptops_models = Model.find(:all, :conditions => ["models.id in (?)", laptops_models_ids])

    results = Hash.new

    group_method = "beginning_of_#{window_size}"
    since = timeRange["date_since"].to_date.send(group_method)
    to = timeRange["date_to"].to_date.send(group_method)

    ProblemType.find(:all, :conditions => ["problem_types.id in (?)", problem_types_ids]).each { |problem_type|

      results[problem_type] = Hash.new
      aux_window = since
      while aux_window <= to
        results[problem_type][aux_window] = 0
        aux_window += 1.send(window_size)
      end

    }
   
    ProblemReport.find(:all, :conditions => cond, :include => inc).each { |problem_report|
   
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

    inc = [{:owner => :performs}, :model]
    cond = ["laptops.created_at <= ? and performs.place_id in (?) and models.id in (?)"]
    cond += [nil, places_ids, laptops_models_ids]

    x_problem_type = results.keys.first
    tabla_tornasol = results[x_problem_type].keys.sort.map { |time_window| 
 
      cond[1] = time_window.send("end_of_#{window_size}")
      Laptop.count(:conditions => cond, :include => inc)
    }

    results.keys.each { |problem_type| 

      @datos.push([problem_type.getName,"", "", "", "", ""])
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
    
      graph_data.push({ :name => problem_type.getName, :value => values })

    }


    @image_name = "/" + PyEducaGraph::createLine(graph_data, _("Average trend"), graph_labels)
    imprimir("problems_time_distribution", "print/" + "report")
  end

  def spare_parts_registry

    print_params = JSON.parse(params[:print_params]).reverse

    inc = [:person, :place, :part_type]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "spare_parts_registries.created_at")

    root_place_id = print_params.pop.to_i
    root_place = Place.find_by_id(root_place_id)
 
    if root_place

      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond, places_ids, "spare_parts_registries.place_id")
    end

    @titulo = _("Incoming repair parts")
    @titulo += "  en #{root_place.getName}" if root_place
    @columnas = [_("Date"), _("Location"), _("Registered by"), _("Assigned to"), _("Device"), _("Part"), _("Quantity")]
    @datos = []

    SparePartsRegistry.find(:all, :conditions => cond, :include => inc, :order => "spare_parts_registries.created_at ASC").each { |registry|

      @datos.push([

        registry.created_at.to_s,
        registry.place.getName,
        registry.person.getFullName,
        registry.owner.getFullName,
        registry.device_serial,
        registry.part_type.getDescription,
        registry.amount
      ])
    }

    imprimir("spare_parts_registry", "print/" + "report")
  end

  def deposits

    print_params = JSON.parse(params[:print_params]).reverse

    inc = [{:problem_solution => :problem_report}]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "bank_deposits.deposited_at")
    
    root_place_id = print_params.pop.to_i
    root_place =  Place.find_by_id(root_place_id)
    places_ids = root_place.getDescendantsIds.push(root_place_id)

    buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")

    results = Hash.new
    BankDeposit.find(:all, :conditions => cond, :include => inc, :order => "bank_deposits.deposited_at ASC").each { |bank_deposit|

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

    imprimir("deposits", "print/" + "report")
  end

  def problems_and_deposits

    print_params = JSON.parse(params[:print_params]).reverse

    inc = [{:problem_solution => [:solution_type, :bank_deposits]}, :problem_type, :owner]
    cond = [""]

    timeRange = print_params.pop
    buildDateQuery(cond, timeRange, "problem_reports.created_at")
    
    root_place_id = print_params.pop.to_i
    root_place =  Place.find_by_id(root_place_id)
    places_ids = root_place.getDescendantsIds.push(root_place_id)

    buildComboBoxQuery(cond, places_ids, "problem_reports.place_id")

    status = print_params.pop
    cond[0] +=  " and problem_reports.solved in (?)"
    cond.push(status)

    results = Hash.new
    results[true] = Array.new
    results[false] = Array.new

    ProblemReport.find(:all, :conditions => cond, :include => inc, :order => "problem_reports.created_at ASC").each { |problem_report|

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
              laptop.getSerialNumber,
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

    imprimir("problems_and_deposits", "print/" + "report")
  end

  def students_ids_distro
    print_params = JSON.parse(params[:print_params]).reverse

    inc_v = [{:performs => [:place, :profile]}]
    cond_v = ["profiles.internal_tag = ?", "student"]

    timeRange = print_params.pop
    buildDateQuery(cond_v, timeRange, "people.created_at")

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
        cond_v[0] += " and performs.place_id in (?)"
        cond_v.push(place.getDescendantsIds.push(place_id))
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

    Person.find(:all, :conditions => cond_v, :include => inc_v).each { |person|

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
    imprimir("students_ids_distro", "print/" + "report")
  end

  def serials_per_places
    print_params = JSON.parse(params[:print_params]).reverse

    places_ids = print_params.pop
    places = nil
    if places_ids != []
      cond = ["places.id in (?)", places_ids]
      places = Place.find(:all, :conditions => cond)
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

    imprimir("serials_per_places", "print/" + "report")
  end

  def online_time_statistics
    print_params = JSON.parse(params[:print_params]).reverse

    #A title hack...
    inc_v = [:event_type]
    cond_v = ["event_types.internal_tag in (?) and (events.extended_info like ? or events.extended_info like ?)"]
    cond_v.push(["node_up","node_down"])
    cond_v.push("%\"type\": \"server\"%")
    cond_v.push("%\"type\": \"ap\"%")

    timeRange = print_params.pop
    range_start = timeRange["date_since"].to_date.beginning_of_day.to_time
    range_end = timeRange["date_to"].to_date.end_of_day.to_time
    cond_v[0] += " and events.created_at > ? and events.created_at < ?"
    cond_v.push(range_start)
    cond_v.push(range_end)

    root_place_id = print_params.pop.to_i
    root_place = Place.find_by_id(root_place_id)
    raise _("Place not found") if !root_place
    root_places_ids = root_place.getDescendantsIds.push(root_place_id)

    results = Hash.new
    Place.find(:all, :conditions => ["places.id in (?)", root_places_ids]).each { |place|

      #finding the parent place and grouping by them...
      place_ids = place.getAncestorsIds.push(place.id)
      inc = [:place_type]
      cond = ["places.id in (?) and place_types.internal_tag = ?", place_ids, "school"]
      parent_place = Place.find(:first, :conditions => cond, :include => inc)     

      #Grouping...
      if parent_place && !results[parent_place]

        results[parent_place] = Hash.new
        inc = [:place, :node_type]
        cond = ["places.id in (?) and node_types.internal_tag not in (?)"]
        cond.push(parent_place.getDescendantsIds.push(parent_place.id))
        cond.push(["center"])

        #Creating nodes entries....
        Node.find(:all, :conditions => cond, :include => inc).each { |node|

          results[parent_place][node] = Hash.new
          results[parent_place][node][:ranges] = Array.new
          results[parent_place][node][:ranges].push( { :range_start => range_start } )
          results[parent_place][node][:ranges].last.merge!({ :waiting_to_close => true })
          results[parent_place][node][:changed_type] = false
        }    
      end
    }

    Event.find(:all, :conditions => cond_v, :include => inc_v, :order => "events.created_at ASC").each { |event|

      info = event.getHash
      node = Node.find_by_id(info["id"])

      if node && root_places_ids.include?(node.place_id)

        place = Place.find_by_id(node.place_id)
        if place

          place_ids = place.getAncestorsIds.push(place.id)
          inc = [:place_type]
          cond = ["places.id in (?) and place_types.internal_tag = ?", place_ids, "school"]
          parent_place = Place.find(:first, :conditions => cond, :include => inc)

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

      label = name+"::#{node.getName}"
      percent = ((time_hours.to_f/(time_hours+off_time_hours).to_f)*100).round
      @datos.push([label, time_hours, off_time_hours, percent])
      graph_data.push({ :name => label, :value => percent })
      }
    }

    @datos.sort! { |a,b| a[3] < b[3] ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createBar(graph_data, _("Percentages"), { :min => 0, :max => 100 })
    imprimir("online_time_statistics", "print/" + "report")
  end

  def where_are_these_laptops
    print_params = JSON.parse(params[:print_params]).reverse

    laptop_serials = print_params.pop.split("\n").map { |line| line.strip.upcase }

    inc_v = [:owner, :assignee]
    cond_v = ["laptops.serial_number in (?)", laptop_serials]

    @datos = []
    found_laptops = []
    Laptop.find(:all, :conditions => cond_v, :include => inc_v).each { |laptop|

      laptop_serial = laptop.getSerialNumber
      location = ""
      owner = laptop.owner
      assignee = laptop.assignee
      if owner:
        location += _("In hands of %s (%s), %s") % [owner.getFullName, owner.getIdDoc, owner.place.getName]
        location += "<br>"
      end
      if assignee:
        location += _("Assigned to %s (%s), %s") % [assignee.getFullName, assignee.getIdDoc, assignee.place.getName]
        location += "<br>"
      end

      status_desc = laptop.getStatus()
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

    imprimir("where_are_these_laptops", "print/" + "report")
  end

  def used_parts_per_person
    print_params = JSON.parse(params[:print_params]).reverse

    inc_v = [{:problem_report => [:place, :owner]}, {:solution_type => :part_types}]
    cond_v = [""]

    person_type = print_params.pop

    place_type_id = print_params.pop.to_i
    
    place_id = print_params.pop.to_i
    place = Place.find_by_id(place_id)      
    if place
      cond_v[0] += "problem_reports.place_id in (?)"
      cond_v.push(place.getDescendantsIds.push(place_id))
    else
      raise _("You must select the location")
    end

    part_ids = print_params.pop
    if part_ids != []
      cond = ["part_types.id in (?)", part_ids]
      cond_v[0] += "and part_types.id in (?)"
      cond_v.push(part_ids)
    else
      cond = []
    end
    part_types = PartType.find(:all, :conditions => cond)

    results = Hash.new
    ProblemSolution.find(:all, :conditions => cond_v, :include => inc_v).each { |problem_solution|

      if person_type == "solved_by_person"
        person = problem_solution.solved_by_person
      else
        person = problem_solution.problem_report.owner
      end

      place = problem_solution.problem_report.place
      ps_part_types = problem_solution.solution_type.part_types

      cond = ["places.id in (?) and places.place_type_id in (?)", place.getAncestorsIds.push(place.id), place_type_id]
      parent_place = Place.find(:first, :conditions => cond)
    
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
    @columnas = [_("Person"), _("Location") ] + part_types.map { |part| part.getDescription } + [_("Total")]
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
        cond = ["id = ? and id in (?)",sort_key, part_types.map { |part| part.id }]
        part_type = PartType.find(:first, :conditions => cond)
        if part_type
          sort_index = @columnas.index(part_type.getDescription)
        else
          raise _("Can't sort by that part.")
        end
    end

    sort_op_key = print_params.pop
    sort_op = "<"
    sort_op = ">" if sort_op_key == "ASC"

    @datos.sort! { |a,b| a[sort_index].send(sort_op, b[sort_index]) ? 1 : -1 }

    imprimir("used_part_per_person", "print/" + "report")
  end

  def problems_per_grade
    print_params = JSON.parse(params[:print_params]).reverse

    inc_v = [{:place => :place_type}, :problem_type]
    cond_v = ["place_types.internal_tag = ?","section"]

    timeRange = print_params.pop
    buildDateQuery(cond_v, timeRange, "problem_reports.created_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      buildComboBoxQuery(cond_v, place.getDescendantsIds.push(place_id), "places.id") if place
    else
      raise _("You must select a location.")
    end
 
    problems_type_ids = print_params.pop
    if problems_type_ids != []
      problems_type_titles = ProblemType.find(problems_type_ids).map { |type| type.name }
      buildComboBoxQuery(cond_v, problems_type_ids, "problem_types.id")
    end

    grade_types = ["first_grade", "second_grade", "third_grade", "fourth_grade", "fifth_grade", "sixth_grade", "seventh_grade", "eighth_grade","ninth_grade"]
    h = Hash.new
    PlaceType.find(:all, :conditions => ["place_types.internal_tag in (?)", grade_types]).each {|type| h[type] = 0 }

    current_year = Date.today.year
    ProblemReport.find(:all, :conditions => cond_v, :include => inc_v).each { |problem_report|

      report_year = problem_report.created_at.year
      rPlace = problem_report.place
      places_ids = rPlace.getAncestorsIds

      inc = [:place_type]
      cond = ["places.id in (?) and place_types.internal_tag in (?)",places_ids, grade_types]

      grade_place = Place.find(:first, :conditions => cond, :include => inc )

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
    imprimir("problems_per_grade", "print/" + "report")
  end

  def problems_per_school
    print_params = JSON.parse(params[:print_params]).reverse

    inc_v = [{:place => :place_type}, :problem_type]
    cond_v = [""]

    timeRange = print_params.pop
    buildDateQuery(cond_v, timeRange, "problem_reports.created_at")

    place_type_id = print_params.pop.to_i

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      buildComboBoxQuery(cond_v, place.getDescendantsIds.push(place_id), "places.id") if place
    end

    problems_type_ids = print_params.pop
    if problems_type_ids != []
      problems_type_titles = ProblemType.find(problems_type_ids).map { |type| type.name }
      buildComboBoxQuery(cond_v, problems_type_ids, "problem_types.id")
    end

    solved_statuses = print_params.pop
    if solved_statuses != []
      cond_v[0]+= "and problem_reports.solved in (?)"
      cond_v.push(solved_statuses)
    end

    sort_criteria = print_params.pop.to_i

    h = Hash.new
    ProblemReport.find(:all, :conditions => cond_v, :include => inc_v).each { |problem_report|

      places_ids = problem_report.place.getAncestorsIds

      inc = [:place_type]
      cond = ["places.id in (?) and place_types.id = ?", places_ids, place_type_id]
      place = Place.find(:all, :conditions => cond, :include => inc).first

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
      name += " (#{place.getDescription})"  if place.getDescription != ""

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
    imprimir("problems_per_place", "print/" + "report")
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
               place_hash[:sub_array].push([person_name, person.id_document, person.profile.description, laptop.getSerialNumber, laptop.getRegistered])
             end
           }
        end
      }

      @hashes_array.push(place_hash)
      end

      places += place.places.reverse  

    end

    imprimir("registered_laptops_status", "print/" + "hashes_array")
  end

  def printable_delivery
    print_params = JSON.parse(params[:print_params]).reverse
    mov_ids = print_params.pop.map {| pair| pair["value"].to_i }
 
    @title = _("Delivery receipt")
    @data = Array.new
   
    cond_v = ["movements.id in (?)", mov_ids]
    include_v = [{:movement_details => :laptop}, :destination_person]
    Movement.find(:all, :conditions => cond_v, :include => include_v).each {|movement|
      h = Hash.new
      h[:id] = movement.id
      h[:parts] = movement.movement_details.map { |detail|
        { :part => "Laptop", :serial => detail.getSerialNumber }
      }
      h[:person] = movement.getDestinationPerson
      @data.push(h)
    }

    imprimir("printable_delivery", "print/" + "printable_delivery")
  end

  def people_laptops
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    root_place = Place.find_by_id(place_id)

    @titulo = _("People of %s and their laptops") % root_place.getName
    @columnas = ["#", _("Name"), _("Document id"), _("Laptop"), _("In hands")]
    @datos = []

    stack = [root_place]
    while(stack != [])
      place = stack.pop
      stack+= place.places.reverse

      second_cond = ["performs.place_id = ?",place.id]
      second_inc = [ { :person => { :laptops_assigned => :status } } ]
      performs = Perform.find(:all, :conditions => second_cond, :include => second_inc, :order => "people.lastname, people.name")
      next if performs.length == 0

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
          status = (laptop.status.internal_tag != "activated") ? laptop.getStatus : nil
          if first:
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
    imprimir("people_laptops", "print/" + "people_laptops")
  end

  def people_documents
    print_params = JSON.parse(params[:print_params]).reverse

    place_id = print_params.pop
    place = Place.find_by_id(place_id)
    raise _("Invalid Place") if not place

    document_filters = print_params.pop
    filters = ""
    filters += "id_document not REGEXP \"_\"" if not document_filters.include?('fake')
    filters += " and " if document_filters.length == 0
    filters += "id_document REGEXP \"_\"" if not document_filters.include?('normal')
    filters += " and " if filters.length != 0

    columns = [_("Location"), _("Name"), _("Document id")]
    rows = []
    student_id = Profile.find_by_internal_tag('student').id

    places = [place]
    while(places != [])
        place = places.pop
        location = place.getName()
        cond_v = ["#{filters} performs.place_id = ? and performs.profile_id = ?", place.id, student_id]
        Person.find(:all, :conditions => cond_v, :include => [:performs]).each { |person|
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
    root_place = Place.find_by_id(place_id)
    raise _("Invalid Place") if root_place.nil?

    relate = { "assignment" => "assignee_id", "physical" => "owner_id" }
    criteria = print_params.pop
    raise _("Invalid Criteria") if relate[criteria].nil?
    relation = relate[criteria]

    buffer = ""

    places_ids = root_place.getDescendantsIds + [root_place.id]
    cond_v = ["place_id in (?)", places_ids]
    people_ids = Perform.find(:all, :conditions => cond_v).collect(&:person_id)

    cond_v = ["serial_number is not NULL and serial_number != \"\""]
    cond_v[0] += " and uuid is not NULL and uuid != \"\""
    cond_v[0] += " and status_id is not NULL and statuses.internal_tag = \"activated\""
    cond_v[0] += " and #{relation} in (?)"
    cond_v.push(people_ids)

    Laptop.find(:all, :conditions => cond_v, :include => [:status]).each { |laptop|
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

    stack = [root_place]
    while(stack != [])
      place = stack.pop

      if place && place.place_type && place.place_type.internal_tag == "section"
        sub_total = 0
        sub_total_con_laptops = 0

        second_cond = ["performs.place_id = ? and performs.profile_id = ?",place.id,student_profile_id]
        second_inc = [:person => :laptops]
        Perform.find(:all, :conditions => second_cond, :include => second_inc).each { |perform|
          person = perform.person

          third_cond = ["people.name = ? and people.id != ?",person.name, person.id]
          possible_clones = Person.find(:all, :conditions => third_cond)
          possible_clones.each { |possible_clone|

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

    imprimir("possible_mistakes", "print/" + "report")
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
      Place.find(:all, :conditions => ["id in (?)",sub_places_ids]).each { |subSubPlace|
        subSubPlace.performs.each { |perform|
          sub_total += perform.person.laptops.length
        }
      }

      name = subPlace.name
      name_str = subPlace.place_type.getName() + " " + name + " - " + subPlace.getDescription()
      h = { :name => name_str, :value => sub_total }
      @datos.push([name_str, subPlace.description, sub_total])
      @grand_total += sub_total
      graph_data.push(h)
    }

    # order by total descending
    @datos.sort! { |a,b| a[2] < b[2] ? 1 : -1 }

    @image_name = "/" + PyEducaGraph::createPie(graph_data,@titulo)
    imprimir("laptops_per_tree", "print/" + "report")
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

    imprimir("lotes", "print/" + "lots_labels")
  end

  def barcodes
    max_place_length = 45
    max_name_length = 26

    print_params = JSON.parse(params[:print_params]).reverse

    places_ids = print_params.pop

    root_places = []
    places = Place.find(:all, :conditions => ["places.id in (?)", places_ids])
    places.each { |root|

      isRoot = true
      places.each { |place|
        isRoot = false if root != place && place.getDescendantsIds.include?(root.id)
      }
   
      root_places.push(root) if isRoot
    }

    filters = print_params.pop

    profiles_ids = print_params.pop

    @num_of_cols = 3
    @all_data = Array.new
    root_places.each { |root_place|

      data = Hash.new
      data[:codes] = Array.new
      data[:times]  = Array.new

      stack = [root_place]
      while(stack != [])

        current_place = stack.pop
        if current_place

          place_info = Hash.new
          place_info[:title] = current_place.getName
          fixed_place_name = place_info[:title]

          if fixed_place_name.length > max_place_length:
            fixed_place_name = "..." + fixed_place_name.mb_chars[-max_place_length..-1].to_s
            place_info[:title] = fixed_place_name
          end

          place_info[:students] = Array.new

          cond_v = ["performs.place_id = ? and profiles.id in (?)", current_place.id, profiles_ids]
          include_v = [{:person => :laptops}, :place, :profile]

          Perform.find(:all, :conditions => cond_v, :include => include_v, :order => "people.lastname, people.name").each { |perform|

            person = perform.person
            laptops = person.laptops
            laptops_assigned = person.laptops_assigned
            print_barcode = ((filters.include?("with") and laptops != []) or
                             (filters.include?("with_out") and laptops == []) or
                             (filters.include?("with_assigned") and laptops_assigned != []) or
                             (filters.include?("with_out_assigned") and laptops_assigned == []))
            if print_barcode
              student = Hash.new
              fixed_person_name = person.getFullName
              if fixed_person_name.length > max_name_length:
                fixed_person_name = fixed_person_name.mb_chars[0..max_name_length].to_s + "..."
              end

              student[:name] = fixed_person_name
              student[:place] = fixed_place_name
              student[:barcode] = person.getBarcode

              place_info[:students].push(student)
            end
          }

          laptops_num = place_info[:students].length
          if laptops_num > 0

            data[:codes].push(place_info)
            times = laptops_num%5==0 ? (laptops_num/5) : ((laptops_num/5)+1)
            data[:times].push(times)
          end
        end

        stack+= current_place.places.reverse

      end
      
      @all_data.push(data)
    }

    imprimir("codigos-usuarios", "print/" + "barcodes", {}, true)
  end

  ####
  # Movements.
  #
  def movements
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    dateOpts = print_params.pop
    buildDateQuery(cond_v, dateOpts, "movements.date_moved_at")

    serials = print_params.pop
    buildSerialQuery(cond_v,serials)

    reasons = print_params.pop
    buildReasonQuery(cond_v,reasons,"movements")

    from_person_id = print_params.pop
    buildPersonQuery(cond_v, from_person_id,"movements.source_person_id")

    to_person_id = print_params.pop
    buildPersonQuery(cond_v, to_person_id,"movements.destination_person_id")

    place_id = print_params.pop
    if place_id.to_i != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      buildComboBoxQuery(cond_v, places, "places.id")
    end

    @titulo = _("Laptop movements")
    @fecha_desde = dateOpts["date_since"]
    @fecha_hasta = dateOpts["date_to"]
    @columnas = [_("Mov \#"), _("Fecha"), _("Desc"), _("Serial"), _("Given by"), _("Received by"), _("Reason")]
    @datos = []

    inc_v = [{:movement_details => :laptop},:movement_type,:source_person, {:destination_person => {:performs => :place}}]
    Movement.find(:all, :include => inc_v, :conditions => cond_v, :order => "movements.id ASC").each  { |m|
      m.movement_details.each { |md|
        @datos.push([
                     md.movement_id,
                     m.getMovementDate(),
                     md.getDescription(),
                     md.getSerialNumber(),
                     m.getSourcePerson(),
                     m.getDestinationPerson(),
                     m.getMovementType()
                    ])
      }
    }

    imprimir("movements", "print/" + "report")
  end

  ###
  # Movement types (totals).
  #
  def movement_types
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    from_person_id = print_params.pop
    buildPersonQuery(cond_v, from_person_id, "movements.source_person_id")

    to_person_id = print_params.pop
    buildPersonQuery(cond_v, to_person_id, "movements.destination_person_id")

    dateOpts = print_params.pop
    buildDateQuery(cond_v, dateOpts, "movements.date_moved_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      buildComboBoxQuery(cond_v, places, "performs.place_id")
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
    include_v = [:movements => [ {:destination_person => :performs}, { :movement_details => :laptop} ] ]
    MovementType.find(:all,:include => include_v,:conditions => cond_v).each { |mt|
      total=laptops=0
      mt.movements.each { |m|
        m.movement_details.each { |md|
          laptops += 1
        }
      }

    h = { :name => mt.getDescription(), :value => laptops } 
    graph_data.push(h)

    v = []
    v.push(mt.getDescription())
    v.push(laptops)
    @datos.push(v)
    }

    @image_name = "/" + PyEducaGraph::createPie(graph_data,@titulo)

    imprimir("movement_types", "print/" + "report")
  end

  ##
  # Movimientos en un vetana de tiempo.
  def movements_time_range
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    dateOpts = print_params.pop
    buildDateQuery(cond_v, dateOpts, "date_moved_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      places = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      buildComboBoxQuery(cond_v, places, "places.id")
    end

    include_v = [{:destination_person => {:performs => :place}}, :source_person, {:movement_details => [:laptop]}]
    movements = Movement.find(:all, :conditions => cond_v,:include => include_v)

    # Se definen los elementos del view.
    @titulo = _("Movements on a given timeframe")
    @fecha_desde = dateOpts["date_since"]
    @fecha_hasta = dateOpts["date_to"]
    @columnas = [_("\#"), _("Date"), _("Parts"), _("Responsible"), _("Delivered by"), _("Received by")]
    @datos = movements.map { |d|
      a = Array.new
      a.push(d.id)
      a.push(d.date_moved_at)
      a.push(d.getParts())
      a.push(d.getResponsible())
      a.push(d.getSourcePerson())
      a.push(d.getDestinationPerson())
      a
    }
    imprimir("movements", "print/" + "report")
  end

  ##
  # Distribution of laptops owned per person. 
  def laptops_per_owner

    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    ownerData = print_params.pop
    buildPersonQuery(cond_v, ownerData, "id")

    @datos = []
    include_v = [:laptops]
    Person.find(:all,:conditions => cond_v,:include => include_v).each { |p|
      
      if p.laptops.length > 0
        @datos.push([p.getFullName(),p.laptops.length])
      end

    }

    # order according number of laptops (descending)
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    @titulo = _("Laptops per owner")
    @columnas = [_("Person"), _("Quantity")]
    imprimir("laptops", "print/" + "report")
  end

  ##
  # Distribution of laptops handed off per person. 
  def laptops_per_source_person
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    source_person = print_params.pop
    buildPersonQuery(cond_v,source_person,"id")

    @titulo = _("Laptops handed out per person")
    @columnas = [_("Person"), _("Quantity")]
    @datos = []
    include_v = [{:source_movements => :movement_details}]
    Person.find(:all,:conditions => cond_v, :include => include_v).each { |p|
      count=0
      p.source_movements.each { |m|
        m.movement_details.each { |md|
          if md.laptop_id
            count+=1
          end
        }
      }
      @datos.push([p.getFullName(),count]) if count != 0
    }

    # Sort by count in descending order
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    imprimir("laptops", "print/" + "report")
  end

  ##
  # God (Dijkstra) forgive me. 
  #
  # FIXME: this almost an *exact* copy of the above method. Refactoring?
  #
  # Distribution of laptops to people.
  def laptops_per_destination_person
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    destination_person = print_params.pop
    buildPersonQuery(cond_v,destination_person,"id")

    @titulo = _("Laptops given to people")
    @columnas = [_("Person"), _("Quantity")]
    @datos = []
    include_v = [{:destination_movements => :movement_details}]
    Person.find(:all,:conditions => cond_v, :include => include_v).each { |p|
      count=0
      p.destination_movements.each { |m|
        m.movement_details.each { |md|
          if md.laptop_id
            count+=1
          end
        }
      }
      @datos.push([p.getFullName(),count]) if count != 0
    }

    # Sort by count in descending order
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    imprimir("laptops", "print/" + "report")
  end
 
  ##
  # Laptops lended. 
  #
  def lendings
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [" return_date is not null "]

    timeRange = print_params.pop
    buildDateQuery(cond_v,timeRange,"date_moved_at")

    sourcePerson = print_params.pop
    buildPersonQuery(cond_v,sourcePerson,"source_person_id")

    destinationPerson = print_params.pop
    buildPersonQuery(cond_v,destinationPerson,"destination_person_id")

    filters = print_params.pop
    if filters.length > 0
      cond_v[0] += " and movement_details.returned = false " if !filters.include? "returned"
      cond_v[0] += " and movement_details.returned = true " if !filters.include? "not_returned"
    end

    @titulo = _("Lendings")
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta = timeRange["date_to"]
    @columnas = [_("#"), _("Date"), _("Given by"), _("Received by"), _("Return date"), _("Part"), _("Serial number"), _("Returned?")]
    @datos =[]
    include_v = [:movement_details]
    counter = 1
    Movement.find(:all,:conditions => cond_v, :order => "date_moved_at DESC", :include => include_v).each { |m|
      m.movement_details.each { |md|
        @datos.push([
                     counter,
                     m.getMovementDate(),
                     m.getSourcePerson(),
                     m.getDestinationPerson(),
                     m.getReturnDate(),
                     md.getDescription(),
                     md.getSerialNumber(),
                     md.getReturned()
                    ])
        counter+=1
      }
    }

    imprimir("prestamos", "print/" + "report")
  end

  ###
  # Laptops grouped by status. 
  #
  def statuses_distribution
    print_params = JSON.parse(params[:print_params]).reverse

    cond_v = ["statuses.internal_tag not in (?)",["used", "broken", "available"]]
    include_v = [:laptops => {:owner => :performs}]

    root_place_id = print_params.pop.to_i
    if root_place_id != -1

      root_place = Place.find_by_id(root_place_id)
      places_ids = root_place.getDescendantsIds.push(root_place_id)
      buildComboBoxQuery(cond_v, places_ids, "performs.place_id") 
    end

    @titulo = _("Distribution of laptops grouped by status")
    @columnas = [_("Status"), _("Quantity")]
    @datos = []

    graph_data = Array.new

    Status.find(:all, :conditions => cond_v ,:include => include_v).each { |s|
      v = []

      v.push(s.getDescription())
      v.push(s.laptops.length)
      @datos.push(v)

      # save for graphing
      total = 0
      v[1..10].each { |i| total += i }
      h = { :name => s.getDescription(), :value => total } 
      graph_data.push(h)
    }

    # TODO: this should be conditional
    @image_name = "/" + PyEducaGraph::createPie(graph_data, @titulo)
 
    imprimir("statuses_distribution", "print/" + "report")
  end

  ###
  # Changes of status. 
  #
  def status_changes
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    timeRange = print_params.pop
    buildDateQuery(cond_v,timeRange,"status_changes.date_created_at")

    @titulo = _("Status changes")
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta = timeRange["date_to"]
    @columnas = [_("Date"), _("Previous"), _("Next"), _("Serial Number")]
    @datos = []

    include_v = [:previous_state,:new_state,:laptop]
    StatusChange.find(:all,:include => include_v,:conditions => cond_v,:order => "status_changes.date_created_at DESC").each {  |sc|
      @datos.push([sc.getDate(),sc.getPreviousState(),sc.getNewState(),sc.getPart(),sc.getSerial()])
    }

    imprimir("cambios_de_estado", "print/" + "report")
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

    imprimir("laptops_por_tipo_localidad", "print/" + "laptops_per_place_type")
  end

  ###
  # Parts replaced. 
  #
  def parts_replaced
    print_params = JSON.parse(params[:print_params]).reverse

    cond_v = [""]
    include_v = [{:problem_report => :place}, {:solution_type => :part_types}]

    timeRange = print_params.pop
    buildDateQuery(cond_v,timeRange,"problem_solutions.created_at")

    group_criteria = print_params.pop
    if ["day","week","month","year"].include?(group_criteria)
      group_method = "beginning_of_"+group_criteria
    else
      raise _("Not allowed")
    end

    place_id = print_params.pop.to_i
    if place_id != -1
      place = Place.find_by_id(place_id)
      buildComboBoxQuery(cond_v, place.getDescendantsIds.push(place_id), "places.id") if place
    end

    part_type_ids = print_params.pop
    if part_type_ids != []
      part_types = PartType.find(:all, :conditions => ["part_types.id in (?)",part_type_ids])
      buildComboBoxQuery(cond_v, part_type_ids, "part_types.id")
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

    ProblemSolution.find(:all, :conditions => cond_v, :include => include_v).each { |ps|

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
    imprimir("repuestos_utilizados", "print/" + "report")
  end

  def problems_per_type
    print_params = JSON.parse(params[:print_params]).reverse
    cond_v = [""]

    timeRange = print_params.pop
    buildDateQuery(cond_v,timeRange,"problem_reports.created_at")

    place_id = print_params.pop.to_i
    if place_id != -1
      subplaces_ids = Place.find_by_id(place_id).getDescendantsIds().push(place_id.to_i)
      buildComboBoxQuery(cond_v,subplaces_ids,"places.id")
    end

    problem_types = print_params.pop
    buildComboBoxQuery(cond_v,problem_types,"problem_types.id")

    @titulo = _("Problems grouped by type") 
    @fecha_desde = timeRange["date_since"]
    @fecha_hasta =  timeRange["date_to"]
    @columnas = [_("Type"), _("Quantity")]
    @datos = []

    graph_data = Array.new
    include_v = [{:problem_reports => [{:laptop => :owner}, :place]}]
    ProblemType.find(:all, :conditions => cond_v, :include => include_v).each { |pt|
      desc = pt.getName()
      amount = pt.problem_reports.length
      @datos.push([desc, amount])
      graph_data.push({ :name => desc, :value => amount })
    }
    @datos.sort! { |a,b| a[1] >= b[1] ?  -1  : 1 }

    @image_name = "/" + PyEducaGraph::createPie(graph_data, _("Distribution"))
    imprimir("problemas_por_tipo", "print/" + "report")
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
      cond = ["serial_number = ?", row[0]]
      inc = [:owner => {:performs => :place}]
      Laptop.find(:all, :conditions => cond, :include => inc).each { |laptop|
        owner = laptop.owner
        location = owner.performs.first.place
        xls_rows.push([serial_number, owner.getFullName, owner.getIdDoc, location.getName])
      }
    }

    file_name = FormatManager.generarExcel2(xls_rows, xls_columns)
    send_file(file_name,:filename => "laptops_check.xls",:type => "application/vnd.ms-excel",:stream => false )
  end

  private
  

  ###
  # Generate the PDF
  #
  #  opciones(Hash):
  #   :margen_superior
  #   :margen_inferior
  #   :margen_izquierdo
  #   :margen_derecho
  #
  def imprimir(pdf_filename,template_file,opciones = Hash.new, output_pdf = true)

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
    if opciones.length > 0
      margen_superior = opciones[:margen_superior] if opciones[:margen_superior]
      margen_inferior = opciones[:margen_inferior] if opciones[:margen_inferior]
      margen_izquierdo = opciones[:margen_izquierdo] if opciones[:margen_izquierdo]
      margen_derecho = opciones[:margen_derecho] if opciones[:margen_derecho]
      letra = opciones[:letra] if opciones[:letra]
      if opciones[:mostrar_nro_pagina]
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
      if output_pdf
        generator = IO.popen(open_arg, "w+")
        # FIXME: we should test if we are in Windows and included the following method call
        # generator.binmode
        generator.puts @template.render(:file => template_file)
        generator.close_write

        send_data(generator.read, :filename => pdf_filename + ".pdf", :type => "application/pdf") 
      end
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


  def buildDateQuery(cond_v, dateOpts, col_canonical_name)

    if dateOpts["date_since"] && dateOpts["date_since"].to_s != ""
      cond_v[0] += " and " if cond_v[0] != ""
      cond_v[0] += " #{col_canonical_name} >= ? "
      cond_v.push(Fecha::usDate(dateOpts["date_since"]))
    end

    if dateOpts["date_to"] && dateOpts["date_to"].to_s != ""
      cond_v[0] += " and " if cond_v[0] != ""
      cond_v[0] += " #{col_canonical_name} <= ? "
      cond_v.push(Fecha::usDate(dateOpts["date_to"]))
    end

    cond_v
  end

  def buildPartQuery(cond_v, partOpts, table_name)
    if partOpts.length > 0 && partOpts.length != 3

      if !partOpts.include? "laptop"
        cond_v[0] += " and " if cond_v[0] != ""
        cond_v[0] += " #{table_name}.laptop_id is null " 
      end
    end
  end

  def buildPersonQuery(cond_v, person_id, col_canonical_name)
    if person_id.to_i != -1
      cond_v[0] += " and " if cond_v[0] != ""
      cond_v[0] += " #{col_canonical_name} = ? "
      cond_v.push(person_id)
    end
  end

  def buildReasonQuery(cond_v,reasons,col_canonical_name)
    if reasons && reasons.length > 0
      cond_v[0] += " and " if cond_v[0] != ""
      cond_v[0] += " #{col_canonical_name}.movement_type_id in (?) "
      cond_v.push(reasons)
    end
  end

  def buildComboBoxQuery(cond_v,cb_options,col_canonical_name)
    if cb_options && cb_options.length > 0
    cond_v[0] += " and " if cond_v[0] != ""
    cond_v[0] += "#{col_canonical_name} in (?)"
    cond_v.push(cb_options)
    end
  end

  def buildSerialQuery(cond_v, cvs_fields)
    if cvs_fields.length > 0
      theres_one = false
      cond_aux = " ( "
      for field in cvs_fields do
        if field["value"] && field["value"] != ""
          theres_one = true
          cond_aux += " or " if cond_aux != " ( "
          cond_aux += "#{field["col_name"].pluralize}.serial_number = ?"
          cond_v.push(field["value"])
        end
      end
      cond_aux += " ) "
      if theres_one
        cond_v[0] += " and " if cond_v[0] != ""
        cond_v[0] += cond_aux
      end
    end
  end

end
