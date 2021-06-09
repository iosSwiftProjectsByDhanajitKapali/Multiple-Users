//
//  SQLiteManager.swift
//  Multiple Users
//
//  Created by unthinkable-mac-0025 on 07/06/21.
//

import Foundation
import SQLite3

class SQLiteManager {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var dataArray = [AccountModel]()
    
    func updateDataInDB(_ userID : String , _ status : String) {
        let updateStatementString = "UPDATE Users SET isParent = '\(status)' WHERE userID = '\(userID)';"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(dbQueue, updateStatementString, -1, &updateStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\nSuccessfully updated row.")
            } else {
                print("\nCould not update row.")
            }
        } else {
            print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func deleteAllDataFromDB()  {
        let deleteStatementString = "DELETE FROM Users;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(dbQueue, deleteStatementString, -1, &deleteStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("\n deleted all rows from DB.")

            } else {
                print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteDataFromDB(with userID : String) {
        
        let deleteStatementString = "DELETE FROM Users WHERE userID = '\(userID)';"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(dbQueue, deleteStatementString, -1, &deleteStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("\nSuccessfully deleted row.")
            } else {
                print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }//:deleteQuery
    
    func insertDataToDB(_ userName : String, _ userID : String , _ isParent : String)  {
        //INSERT QUERY
        let insertStatementString = "INSERT INTO Users (userID, userName, isParent) VALUES (?,?,?);"

        var insertStatementQuery : OpaquePointer?

        if(sqlite3_prepare_v2(dbQueue, insertStatementString, -1, &insertStatementQuery, nil)) == SQLITE_OK{
            sqlite3_bind_text(insertStatementQuery, 1, userID , -1 , SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatementQuery, 2, userName , -1 , SQLITE_TRANSIENT)
            sqlite3_bind_text(insertStatementQuery, 3, isParent , -1 , SQLITE_TRANSIENT)

            if(sqlite3_step(insertStatementQuery)) == SQLITE_DONE{
               
                print("Successfully Inserted the Records")
            }else{
                print("Error inserting the records")
            }

            sqlite3_finalize(insertStatementQuery)
        }
    }
    
    func getAllDataFromDB() -> [AccountModel]{
        //print("fetching users from SQLite-DB")
        
        let selectStatementString = "SELECT userID, userName, isParent FROM Users"
        var selectStatementQuery : OpaquePointer?
        var name : String! = ""
        var id : String! = ""
        var status : String = ""
        
        if(sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil)) == SQLITE_OK{
            
            while sqlite3_step(selectStatementQuery) == SQLITE_ROW{
                
                id = String(cString: sqlite3_column_text(selectStatementQuery, 0))
                name = String(cString: sqlite3_column_text(selectStatementQuery, 1))
                status = String(cString: sqlite3_column_text(selectStatementQuery, 2))
                
                dataArray.append(AccountModel(name: name, id: id, isParent: status))
                
            }
            
            sqlite3_finalize(selectStatementQuery)
        }
        return dataArray
    }
}
