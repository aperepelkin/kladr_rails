namespace :kladr do

  def load_address_types(dbf)
    dbf.each do |record|
      AddressType.find_or_create_by(name: record.scname) do |r|
        r.description = record.socrname
        r.level = record.level
        r.code = record.kod_t_st
      end
    end
  end

  def load_areas(dbf)
    #codes = Area.select(:code).collect{|c| c.code}.to_set
    areas = []

    dbf.each_with_index do |record, index|
      attributes = {
          name: record.name,
          socr: record.socr,
          code: record.code,
          index: record.index,
          gninmb: record.gninmb,
          uno: record.uno,
          ocatd: record.ocatd,
          status: record.status,
          address_type_id: (@address_types[record.socr].present? ? @address_types[record.socr].id : nil),
          level: @address_types[record.socr].level
      }.merge parse_code record.code

      #if codes.include? record.code
      #  Area.where(code: record.code).update_all(attributes)
      #else
      areas << Area.new(attributes)
      p index if index % 10000 == 0
      #end
    end
    Area.import areas, {:validate => false}
  end

  def load_streets(dbf)
    codes = {}
    Area.select(:code, :id).each{ |r| codes[r.code] = r.id }

    streets = []
    dbf.each_with_index do |record, index|
      attributes = {
          name: record.name,
          socr: record.socr,
          code: record.code,
          index: record.index,
          gninmb: record.gninmb,
          uno: record.uno,
          ocatd: record.ocatd,
          address_type_id: (@address_types[record.socr].present? ? @address_types[record.socr].id : nil)
      }.merge parse_code record.code

      attributes[:parent_id] = codes[
          attributes[:subject_code] +
              attributes[:region_code] +
              attributes[:city_code] +
              attributes[:settlement_code] + '00'
      ]

      #if codes.include? record.code
      #  Street.where(code: record.code).update_all(attributes)
      #else
      streets << Street.new(attributes)
      p index if index % 10000 == 0
      if index % 100000 == 0
        Street.import streets, {:validate => false}
        streets = []
      end
      #end
    end
    Street.import streets, {:validate => false}
  end

  def load_buildings(dbf)
    codes = {}
    Street.select(:code, :id).each{ |r| codes[r.code] = r.id }
    areas = {}
    Area.select(:code, :id).each{ |r| codes[r.code] = r.id }

    buildings = []

    dbf.each_with_index do |record, index|
      attributes = {
          name: record.name,
          socr: record.socr,
          code: record.code,
          index: record.index,
          gninmb: record.gninmb,
          uno: record.uno,
          ocatd: record.ocatd,
          address_type_id: (@address_types[record.socr].present? ? @address_types[record.socr].id : nil)
      }.merge parse_code record.code

      attributes[:parent_id] = codes[
          attributes[:subject_code] +
              attributes[:region_code] +
              attributes[:city_code] +
              attributes[:settlement_code] +
              attributes[:street_code] + '00'
      ]

      attributes[:parent_id] = areas[
          attributes[:subject_code] +
              attributes[:region_code] +
              attributes[:city_code] +
              attributes[:settlement_code] + '00'
      ] if attributes[:parent_id].nil?
      #if codes.include? record.code
      #  Building.where(code: record.code).update_all(attributes)
      #else
      buildings << Building.new(attributes)
      p index if index % 10000 == 0
      if index % 100000 == 0
        Building.import buildings, {:validate => false}
        buildings = []
      end
      #end
    end
    Building.import buildings, {:validate => false}
  end

  def parse_code(code)
    h = {
        subject_code: code[0,2],
        region_code: code[2,3],
        city_code: code[5,3],
        settlement_code: code[8,3]
    }
    h[:street_code] = code[11,4] if code.length > 13
    h[:building_code] = code[15,4] if code.length > 17
    h[:clean_code] = h.values.inject{|s, i| s + i}
    h[:active_code] = code[code.length - 2, 2] if code.length < 19
    h[:active] = code[code.length - 2, 2].eql?('00') if code.length < 19
    h
  end

  def area_relations
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code and p.region_code = a.region_code and p.city_code = a.city_code
      and p.settlement_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.settlement_code <> '000'").to_s
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code and p.region_code = a.region_code
      and p.settlement_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.settlement_code <> '000'").to_s
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code
      and p.settlement_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.settlement_code <> '000'").to_s
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code and p.region_code = a.region_code
      and p.settlement_code = '000' and p.city_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.city_code <> '000'").to_s
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code
      and p.settlement_code = '000' and p.city_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.city_code <> '000'").to_s
    p 'Updated rows: ' + Area.connection.update_sql("update areas a inner join areas p on
      p.subject_code = a.subject_code
      and p.settlement_code = '000' and p.city_code = '000' and p.region_code = '000' and p.active = 1
		  set a.parent_id = p.id
       where a.parent_id is null and a.region_code <> '000'").to_s
  end

  task :load => :environment do

    Area.delete_all
    Street.delete_all
    #Building.delete_all

    p 'KLADR loading....'
    dir = Rails.root.to_s + '/files/kladr/'
    load_address_types DBF::Table.new(dir + 'SOCRBASE.DBF')
    p 'Address Types loaded'
    @address_types = {}
    AddressType.select(:name, :id, :level).each{ |r| @address_types[r.name] = r }

    load_areas DBF::Table.new(dir + 'KLADR.DBF')
    p 'Areas loaded'
    load_streets DBF::Table.new(dir + 'STREET.DBF')
    p 'Streets loaded'
    #load_buildings DBF::Table.new(dir + 'DOMA.DBF')
    #p 'Buildings loaded'

    area_relations
    p 'Area relations builded'

    p 'KLADR loaded'

  end

  task :relation => :environment do

    Area.update_all(parent_id: nil)
    area_relations

  end

end