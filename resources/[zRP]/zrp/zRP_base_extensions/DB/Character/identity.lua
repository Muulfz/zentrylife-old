---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 11/17/2018 8:12 PM
---

-- init sql
zRP.prepare("zRP/identity_tables", [[
CREATE TABLE IF NOT EXISTS zrp_user_identities(
  user_id VARCHAR(36),
  registration VARCHAR(20),
  phone VARCHAR(20),
  firstname VARCHAR(50),
  name VARCHAR(50),
  age INTEGER,
  CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
  CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES zrp_users(id) ON DELETE CASCADE,
  INDEX(registration),
  INDEX(phone)
);
]])


zRP.prepare("zRP/get_user_identity","SELECT * FROM zrp_user_identities WHERE user_id = @user_id")
zRP.prepare("zRP/init_user_identity","INSERT IGNORE INTO zrp_user_identities(user_id,registration,phone,firstname,name,age) VALUES(@user_id,@registration,@phone,@firstname,@name,@age)")
zRP.prepare("zRP/update_user_identity","UPDATE zrp_user_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE user_id = @user_id")
zRP.prepare("zRP/get_userbyreg","SELECT user_id FROM zrp_user_identities WHERE registration = @registration")
zRP.prepare("zRP/get_userbyphone","SELECT user_id FROM zrp_user_identities WHERE phone = @phone")
