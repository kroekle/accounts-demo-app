import React, {useState, useEffect} from 'react';
import { Select, MenuItem, TableContainer, Table, TableHead, TableRow, TableCell, TableBody, TableFooter, TablePagination, Link, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, Button, Autocomplete, TextField } from '@mui/material';
import { Authz, useAuthz } from '@styra/opa-react';
import { enqueueSnackbar } from 'notistack';
import {NumericFormat as NumberFormat} from 'react-number-format';

function AccountList({ title, svc , regions, setError, setBalanceLimit, setRegionLimit, setWarnings, allAccounts}) {
    const [accounts, setAccounts] =  useState([]);
    const [selectedRegion, setSelectedRegion] =  useState('x');
    const [force, setForce] = useState(false);

    useEffect(() => {

      const fetchData = async () => {
        const handleResponse = (resp) =>  {
          if (resp.status === 200) {
            if (resp.headers.has("X-Blocked-Region")) {
              setRegionLimit(true)
            } else {
                setRegionLimit(false);
            }
            if (resp.headers.has("X-Balance-Limit")) {
              setBalanceLimit(true)
            } else {
                setBalanceLimit(false);
            }
            if (resp.headers.has("X-Warnings")) {
              setWarnings(resp.headers.get("X-Warnings"))
            } else {
                setWarnings("")
            }
            setError("")
            return resp.json()
          }
          setError(resp.body)
        }

        if (svc) {
          let call = svc.listAll(selectedRegion)
          fetch(call.path, call.options)
            .then(resp => handleResponse(resp))
            .then(json => setAccounts(json))
            .catch(e => console.log(e));
        }
      };
      fetchData();
    }, [selectedRegion, svc, setError, setRegionLimit, setBalanceLimit, setWarnings, force]);

    const handleRegionChange = (event) => {
      setSelectedRegion(event.target.value);
    };

    const [page, setPage] = useState(0);
    const [rowsPerPage, setRowsPerPage] = useState(5);

    const handleChangePage = (event, newPage) => {
      setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
      setRowsPerPage(parseInt(event.target.value, 10));
      setPage(0);
    };

    return (
      <div>
        <h2>{title}</h2>
        <Select value={selectedRegion} onChange={handleRegionChange}>
          {regions.map((region) => (
            <MenuItem key={region[0]} value={region[0]}>
              {region[1]}
            </MenuItem>
          ))}
        </Select>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Account</TableCell>
                <TableCell>Manager</TableCell>
                <TableCell>Balance</TableCell>
                <TableCell>Region</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {accounts && (rowsPerPage > 0
          ? accounts.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
          : accounts
        ).map((item) => item.holderName && (
                <TableRow key={item.id}>
                  <TableCell>{item.holderName}</TableCell>
                  <TableCell>{item.manager.name}</TableCell>
                  <TableCell className="right">{item.balance.toLocaleString()}</TableCell>
                  <TableCell className="center">{item.region}</TableCell>
                  <TableCell className="center">{item.status}</TableCell>
                  <TableCell className="center">
                  {item.status === "ACTIVE" && (
                    <Authz input={svc.closeAccount(item.id)} fromResult={result => result.allowed}>
                      <Close accountId={item.id} svc={svc} setForce={setForce}/>
                    </Authz>)}
                  {item.status === "ACTIVE" && (
                    <Authz input={svc.transferFunds(item.id, '', 0)} fromResult={result => result.allowed}>
                      <Transfer accountId={item.id} svc={svc} allAccounts={allAccounts} setForce={setForce}/>
                    </Authz>)}
                  {item.status === "INACTIVE" && (<Authz input={svc.reopenAccount(item.id)} fromResult={result => result.allowed}>
                      <Reopen accountId={item.id} svc={svc} setForce={setForce}/>
                    </Authz>)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
            <TableFooter>
              <TableRow>
                <TablePagination
                  rowsPerPageOptions={[5, 10, { label: 'All', value: -1 }]}
                  colSpan={6}
                  count={(accounts && accounts.length)?accounts.length:0}
                  rowsPerPage={rowsPerPage}
                  page={page}
                  slotProps={{
                    select: {
                      inputProps: {
                        'aria-label': 'rows per page',
                      },
                      native: true,
                    },
                  }}
                  onPageChange={handleChangePage}
                  onRowsPerPageChange={handleChangeRowsPerPage}
                />
              </TableRow>
            </TableFooter>
          </Table>
        </TableContainer>

      </div>
    );
  }

  export default AccountList;

  function Reopen({accountId, svc, setForce}) {

    const [open, setOpen] = useState(false);

    const reopenAccount = () => {
      let call = svc.reopenAccount(accountId);
      fetch(call.path, call.options)
        .then(resp => {
          if (resp.status === 200) {
            setForce((force) => !force);
            enqueueSnackbar("Account Reopened ", {"variant": "success"});
          } else if (resp.status === 403) {
              enqueueSnackbar("Forbidden", {"variant": "error"});
          } else {
            enqueueSnackbar(`Could not reopen account: ${resp.statusText}`, {"variant": "error"})
          }
          setOpen(false);
        })
        .catch(resp => enqueueSnackbar(`Could not reopen account: ${resp.statusText}`, {"variant": "error"}))
    }
    return (
      <>
        <Link color="inherit" underline='hover' onClick={()=>setOpen(!open)}>Reopen</Link>
        <Dialog
          open={open}
          onClose={() => setOpen(false)}
          aria-labelledby="responsive-dialog-title"
        >
          <DialogTitle id="responsive-dialog-title">
            Reopen Account?
          </DialogTitle>
          <DialogContent>
            <DialogContentText>
              Reopening the account will allow further actions on the account.
            </DialogContentText>
          </DialogContent>
          <DialogActions>
            <Button autoFocus onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button onClick={reopenAccount} autoFocus>
              Continue
            </Button>
          </DialogActions>
        </Dialog>
      </>
    )

  }

  function Close({accountId, svc, setForce}) {

    const [open, setOpen] = useState(false);

    const closeAccount = () => {
      let call = svc.closeAccount(accountId);
      fetch(call.path, call.options)
        .then(resp => {
          if (resp.status === 200) {
            setForce((force) => !force);
            enqueueSnackbar("Account Closed", {"variant": "success"});
          } else if (resp.status === 403) {
              enqueueSnackbar("Forbidden", {"variant": "error"});
          } else {
            enqueueSnackbar(`Could not close account: ${resp.statusText}`, {"variant": "error"})
          }
          setOpen(false);
        })
        .catch(resp => enqueueSnackbar(`Could not close account: ${resp.statusText}`, {"variant": "error"}))
    }
    return (
      <>
        <Link color="inherit" underline='hover' onClick={()=>setOpen(!open)}>Close</Link>
        <Dialog
          open={open}
          onClose={() => setOpen(false)}
          aria-labelledby="responsive-dialog-title"
        >
          <DialogTitle id="responsive-dialog-title">
            Close Account?
          </DialogTitle>
          <DialogContent>
            <DialogContentText>
              Closing the account will disable any further actions on the account.
            </DialogContentText>
          </DialogContent>
          <DialogActions>
            <Button autoFocus onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button onClick={closeAccount} autoFocus>
              Continue
            </Button>
          </DialogActions>
        </Dialog>
      </>
    )

  }

  function Transfer({accountId, svc, allAccounts, setForce}) {

    const [open, setOpen] = useState(false);
    const [amount, setAmount] = useState();
    const [account, setAccount] = useState(null);
    const [options, setOptions] = useState([]);
    const [accountName, setAccountName] = useState();
    const [canContinue, setCanContinue] = useState(false);

    // useEffect(() => {
    //   if (account && amount) {
    //     setCanContinue(useAuthz([{
    //       input: svc.transferFunds(accountId, account.id, amount.replaceAll(',', '')) ,
    //       fromResult: (result) => result.allowed
    //     }]))
    //   }
    // }, [account, amount, accountId, svc])

    useEffect(() => {
      if (allAccounts && allAccounts.length > 0) {

        setOptions(allAccounts.map(a => {
            return {"id":a.id, "name":`${a.holderName} (${a.region})`}
        }
        ).sort((a,b) => a.name.localeCompare(b.name))
        .filter(a =>  a.id.localeCompare(accountId) !== 0)
        );
  
        let account = allAccounts.find(a => a.id.localeCompare(accountId) === 0)
        if (account) {
          setAccountName(account.holderName)
        }
      }

    }, [allAccounts, accountId])

    const transferFunds = () => {
      let call = svc.transferFunds(accountId, account.id, amount.replaceAll(',', ''));
      fetch(call.path, call.options)
        .then(resp => {
          if (resp.status === 200) {
            enqueueSnackbar("Money Transferred", {"variant": "success"});
            setForce((force) => !force);
          } else if (resp.status === 403) {
            //do something else
            enqueueSnackbar(`Forbidden`, {"variant": "error"})
          }
          setOpen(false);
        })
        .catch(resp => enqueueSnackbar(`Could not transfer Funds: ${resp.statusText}`, {"variant": "error"}))
    }
    return (
      <>
        <Link color="inherit" underline='hover' onClick={()=>setOpen(!open)}>Txfr</Link>
        <Dialog
          open={open}
          onClose={() => setOpen(false)}
          aria-labelledby="responsive-dialog-title"
        >
          <DialogTitle id="responsive-dialog-title">
            Transfer Funds: {accountName}
          </DialogTitle>
          <DialogContent>
            <DialogContentText>
              This will transfer funds to another account.
            </DialogContentText>
            <Autocomplete
              disablePortal
              id="account"
              options={options}
              getOptionLabel={option => option.name?option.name:""}
              isOptionEqualToValue={(option, value)=>option?.id === value?.id}
              sx={{ width: 300 }}
              value={account}
              onChange={(event, newValue) => setAccount(newValue)}
              renderInput={(params) => <TextField {...params} label="To Account" variant="standard" />}
            />
            <TextField 
              id="amount" 
              value={amount} 
              onChange={event => setAmount(event.target.value)} 
              label="Amount" 
              variant="standard" 
              InputProps={{ inputComponent: DollarInput }}
              />

          </DialogContent>
          <DialogActions>
            <Button autoFocus onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button onClick={transferFunds} disabled={!amount || !account || !canContinue} autoFocus>
              Continue
            </Button>
            {/* <Authz 
              input={svc.transferFunds(accountId, account?.id || 0, amount?.replaceAll(',', '') || 0)} 
              fromResult={result => result.allowed}
              fallback={<Button disabled>Continue</Button>}>
                <Button onClick={transferFunds} disabled={!amount || !account}>
                  Continue
                </Button>
            </Authz> */}
          </DialogActions>
        </Dialog>
      </>
    )

  }

  const DollarInput = ({ value, onChange, ...otherProps }) => {
    return (
      <NumberFormat
        thousandSeparator={true}
        decimalScale={0}
        fixedDecimalScale={true}
        allowNegative={false}
        value={value}
        onChange={onChange}
        {...otherProps}
      />
    );
  };