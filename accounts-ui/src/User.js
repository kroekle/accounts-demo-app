import { useEffect, useState } from "react";
import React from "react";

import { Select, MenuItem, Avatar } from "@mui/material";

const users = [
    {
      "id": "alice",
      "name": "Alice Doe",
      "initials": "AD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoiaGVscGRlc2siLCJjb21wYW55Ijoic3R5cmEiLCJkZXBhcnRtZW50TnVtYmVyIjoiY2MiLCJlbXBsb3llZU51bWJlciI6IjEwIiwiZW1wbG95ZWVUeXBlIjoicGFydHRpbWUiLCJnaWROdW1iZXIiOiI1MDAyIiwicm9sZXMiOlsiZ2xvYmFsOndyaXRlciIsImdsb2JhbDphZG1pbiIsImdsb2JhbDpyZXZpZXdlciIsInVzOnJlYWRlciJdLCJwaHlzaWNhbERlbGl2ZXJ5T2ZmaWNlTmFtZSI6IkVBU1QiLCJ0aXRsZSI6Im1hbmFnZXIiLCJzdWIiOiI1MDAyIn0.EGPC_EctMPbyNwhieAKRiXLiVnPcnj9Pq_G-Yo0Esyc"
    },
    {
      "id": "kurt",
      "name": "Kurt Doe",
      "initials": "KD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5Ijoic2FsZXMiLCJjb21wYW55Ijoic3R5cmEiLCJkZXBhcnRtZW50TnVtYmVyIjoic2EiLCJlbXBsb3llZU51bWJlciI6IjQzIiwiZW1wbG95ZWVUeXBlIjoiZnVsbHRpbWUiLCJnaWROdW1iZXIiOiI1MDAxIiwicm9sZXMiOlsiZ2xvYmFsOmFkbWluIiwidXM6YWRtaW4iXSwicGh5c2ljYWxEZWxpdmVyeU9mZmljZU5hbWUiOiJ3aXNjb25zaW4iLCJwb3N0YWxBZGRyZXNzIjoiVVMiLCJ0aXRsZSI6ImFkbWluIiwic3ViIjoiNTAwMSJ9.uao0sY8ejWipUnVT-v24o_bcY4812zrwpBX28Wj1r8s"  
    
    },
    {
      "id": "tim",
      "name": "Tim Doe",
      "initials": "TD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoibGVhZGVyc2hpcCIsImNvbXBhbnkiOiJzdHlyYSIsImRlcGFydG1lbnROdW1iZXIiOiJlbmdpbmVlcmluZyIsImVtcGxveWVlTnVtYmVyIjoiMSIsImVtcGxveWVlVHlwZSI6ImZ1bGx0aW1lIiwiZ2lkTnVtYmVyIjoiNTAwMyIsInJvbGVzIjpbImdsb2JhbDp2aWV3ZXIiLCJ1czp3cml0ZXIiLCJ1czpyZXZpZXdlciJdLCJwaHlzaWNhbERlbGl2ZXJ5T2ZmaWNlTmFtZSI6ImNhbGlmb3JuaWEiLCJwb3N0YWxBZGRyZXNzIjoiVVMiLCJ0aXRsZSI6IkNUTyIsInN1YiI6IjUwMDMifQ.ns2gQks0TQtz_1RH3QCm4FhL4jwCYlSxveN5RXUG6tU"
    }
  ]

function User ({setToken}) {

    const [user, setUser] = useState("alice");
    useEffect(() => {
        setToken(users.find(u => u.id === user).token);
    }, [user, setToken]);
    return (
      <div className="user">
        <Select value={user} onChange={(event) => setUser(event.target.value)}>
          {users.map((u) => (
            
            <MenuItem key={u.id} value={u.id}>
              <div className="login">
                <Avatar>{u.initials}</Avatar>
                <div className="login-name">{u.name}</div>
              </div>
            </MenuItem>
          ))}
        </Select>
      </div>
    )
  }

  export default User;