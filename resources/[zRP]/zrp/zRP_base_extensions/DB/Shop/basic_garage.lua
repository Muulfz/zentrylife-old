zRP.prepare("zRP/vehicles_table", [[
CREATE TABLE IF NOT EXISTS zrp_user_vehicles(
  user_id INTEGER,
  vehicle VARCHAR(100),
  upgrades text not null,
  seized BOOLEAN default 0,
  CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
  CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES zrp_users(id) ON DELETE CASCADE
);
]])

zRPBase.tables[10] = "zRP/vehicles_table"

zRP.prepare("zRP/add_vehicle", "INSERT IGNORE INTO zrp_user_vehicles(user_id,vehicle) VALUES(@user_id,@vehicle)")
zRP.prepare("zRP/add_full_vehicle", "INSERT IGNORE INTO zrp_user_vehicles(user_id, vehicle, upgrades) VALUES(@user_id, @vehicle, @upgrades)")
zRP.prepare("zRP/remove_vehicle", "DELETE FROM zrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
zRP.prepare("zRP/get_vehicles", "SELECT vehicle FROM zrp_user_vehicles WHERE user_id = @user_id")
zRP.prepare("zRP/get_vehicles_unseized", "SELECT vehicle FROM zrp_user_vehicles WHERE user_id = @user_id AND seized = false")
zRP.prepare("zRP/get_vehicle", "SELECT vehicle FROM zrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
zRP.prepare("zRP/get_vehicle_upgrades", "SELECT upgrades FROM zrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND upgrades IS NOT NULL")

zRP.prepare("zRP/alter_vehicles_table","alter table zrp_user_vehicles add if not exists upgrades text")
zRP.prepare("zRP/update_vehicle_upgrades","update zrp_user_vehicles SET upgrades = @upgrades WHERE user_id = @user_id and vehicle = @model")

zRP.prepare("zRP/sale_table", [[
CREATE TABLE IF NOT EXISTS zrp_sale_vehicles(
  user_id INTEGER,
  vehicle VARCHAR(100),
  price integer default 1,
  description varchar(131) not null,
  upgrades text not null,
  CONSTRAINT pk_sale_vehicles PRIMARY KEY(user_id,vehicle),
  CONSTRAINT fk_sale_vehicles_users FOREIGN KEY(user_id) REFERENCES zrp_users(id) ON DELETE CASCADE
);
]])

zRPBase.tables[11] = "zRP/sale_table"

zRP.prepare("zRP/add_sale_vehicle", "INSERT IGNORE INTO zrp_sale_vehicles(user_id, vehicle, price, description, upgrades) VALUES(@user_id, @vehicle, @price, @description, @upgrades)")
zRP.prepare("zRP/remove_sale_vehicle", "DELETE FROM zrp_sale_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
zRP.prepare("zRP/get_sale_vehicle", "SELECT * FROM zrp_sale_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
zRP.prepare("zRP/get_sale_vehicles", "SELECT vehicle FROM zrp_sale_vehicles WHERE user_id = @user_id")
zRP.prepare("zRP/get_all_sale_vehicles", "SELECT * FROM zrp_sale_vehicles")

zRP.prepare("zRP/get_remove_vehicle", "SELECT vehicle FROM zrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle;DELETE FROM zrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
zRP.prepare("zRP/get_remove_sale_vehicle", "SELECT * FROM zrp_sale_vehicles WHERE user_id = @user_id AND vehicle = @vehicle;DELETE FROM zrp_sale_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")

zRP.prepare("zRP/set_sale_vehicle", "update zrp_sale_vehicles set price = @price, description = @description where user_id = @user_id and vehicle = @vehicle")

