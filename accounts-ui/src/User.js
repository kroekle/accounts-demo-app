import { useEffect, useState } from "react";
import React from "react";

import { Select, MenuItem, Avatar } from "@mui/material";

const users = [
    {
      "id": "alice",
      "name": "Alice Doe",
      "initials": "AD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiTk9SVEgiLCJFVVJPUEUiXSwidGVycml0b3JpZXMiOlsidXMiLCJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImVtcGxveWVlTnVtYmVyIjoiMSIsIm5hbWUiOiJBbGljZSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnRyYW5zZmVycyIsImludGVybmF0aW9uYWw6YWRtaW4iLCJ1czp0cmFuc2ZlcnMiLCJ1czphZG1pbiJdLCJ0aXRsZSI6Ikdsb2JhbCBNYW5hZ2VyIiwic3ViIjoiNTAwMSJ9.YSwWjoj6H_6mPQaVum3310RLtKkMm48bYwNv2EptRko"
    },
    {
      "id": "kurt",
      "name": "Kurt Doe",
      "initials": "KD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiV0VTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJlbXBsb3llZU51bWJlciI6IjIiLCJuYW1lIjoiS3VydCBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnZpZXdlciIsInVzOnRyYW5zZmVycyJdLCJ0aXRsZSI6IlVTIEZ1bmRzIE1hbmFnZXIiLCJzdWIiOiI1MDAyIn0.S_6md8GZkyjEvLgP-w1j-Zz2ue21RmsULdI4B3B-jp8"  
    
    },
    {
      "id": "tim",
      "name": "Tim Doe",
      "initials": "TD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiRUFTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJlbXBsb3llZU51bWJlciI6IjMiLCJuYW1lIjoiVGltIERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6YWRtaW4iXSwidGl0bGUiOiJVUyBBY2NvdW50IFN1cGVydmlzb3IiLCJzdWIiOiI1MDAzIn0.YphmCJYU13Q6FOM_v2TQqCOrWwKfcGSGRrwAL8_s2xA"
    },
    {
      "id": "sue",
      "name": "Sue Doe",
      "initials": "SD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiQVNJQSJdLCJ0ZXJyaXRvcmllcyI6WyJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImVtcGxveWVlTnVtYmVyIjoiNCIsIm5hbWUiOiJTdWUgRG9lIiwicm9sZXMiOlsiaW50ZXJuYXRpb25hbDp2aWV3ZXIiLCJ1czp2aWV3ZXIiXSwidGl0bGUiOiJHbG9iYWwgU3VwcG9ydCBTcGVjaWFsaXN0Iiwic3ViIjoiNTAwNCJ9.xQSlQKmEKppRFMT-RmRRMOS_d3dPs6U47vdbzfxaJ2M"
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