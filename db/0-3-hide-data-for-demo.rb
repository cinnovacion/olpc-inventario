def confuse_people

  Person.all.each { |person|
  
    person.name = "nombre_#{rand(999999999)}"
    person.lastname = "apellido_#{rand(999999999)}"
    person.id_document = (person.id_document.match("^[0-9]+$")) ? rand(999999999).to_s : "ID_#{rand(999999999)}"
    person.phone = rand(9999999999).to_s
    person.cell_phone = rand(9999999999).to_s
    person.email = "#{rand(9999999999)}@tch.org"
    person.save
  }

  true
end

def confuse_users

  User.all.each { |user|

    if user.usuario != "admin"
      user.usuario = "user_#{rand(999999999)}"
      user.clave = "password_#{rand(999999999)}"
      user.save
    end
  }

  true
end

def confuse_deposits

  BankDeposit.all.each { |deposit|

    deposit.deposit = (100000000 + rand(999999999999)).to_s
    deposit.amount = 15000 + rand(100000)
    deposit.bank = "Friendly Bank"
    deposit.save
  }

  true
end

def confuse_laptops

  fake_serial = ""
  Laptop.all.each { |laptop|  

    loop do
      fake_serial = "TCH#{rand(999999999)}"
      break if !Laptop.find_by_serial_number(fake_serial)
    end

    laptop.serial_number = fake_serial
    laptop.save
  }

  true
end

def confuse_nodes

  Node.all.each { |node|

    node.username = "user_#{rand(9999999999)}"
    node.password = rand(9999999999).to_s
    node.save
  }

end

confuse_nodes
confuse_people
confuse_users
confuse_deposits
confuse_laptops
