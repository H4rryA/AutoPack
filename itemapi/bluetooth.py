import pymongo
import serial

ser = serial.Serial('/dev/tty.RN42-RNI-SPP', 115200)
mongoc = pymongo.MongoClient("mongodb://localhost:27017/")
mongodb = mongoc["itemsdb"]
col = mongodb["items"]

print("Bluetooth Ready")

while ser.is_open :
  x = ser.read_until()
  y = x.decode("utf-8")

  # Parse RFID and Pocket number
  byte = y.split(' ')
  rfid = ''.join(byte[:-1])
  pocket = int(byte[-1]) - 1

  print(rfid, pocket)
  # Determine whether item is new
  item = col.find_one({"RFID": rfid})
  print(item)
  if item == None :
    print("New Item")
    col.insert_one({ "name": "New Item", "RFID": rfid, "status": pocket})  
  else:
    query = {"RFID": rfid}
    if item["status"] == 2 :
      values = { "$set": {"status": pocket}}
      col.update_one(query, values)
    else:
      values = { "$set": {"status": 2}}
      col.update_one(query, values)
