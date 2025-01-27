import React from "react";
import './PolicyTypes.css';

import { useEffect, useState } from "react";

import Accordion from '@mui/material/Accordion';
import AccordionSummary from '@mui/material/AccordionSummary';
import AccordionDetails from '@mui/material/AccordionDetails';
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';

function PolicyTypes ({selectedType}) {

  const [expanded, setExpanded] = useState('')

  const handleChange = (panel) => (event, isExpanded) => {
    setExpanded(isExpanded ? panel : false);
  };

  useEffect(() => {
    console.log('selectedType: '+ selectedType)
    if (selectedType === 0) 
      setExpanded('RBAC')
    else if (selectedType === 10)
      setExpanded('ABAC')
    else if (selectedType === 20)
      setExpanded('ReBAC')
    else if (selectedType === 30)
      setExpanded('PBAC')
  }, [selectedType])

  return (
    <div className="Desc">
      <Accordion expanded={expanded === 'PBAC'} onChange={handleChange('PBAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}>
            PBAC
          </AccordionSummary>
        <AccordionDetails className="DescText">
          <p>PBAC isn't necessarily a authorization model of it's own, but rather a way of expressing any policy model in code.  It should be able to express any of the other types of authorization models individually or together to create any access control that you may need.</p>
          <p>Within this application, when PBAC is in use, ABAC principles will be used for basic close/transfer actions.  But also will use ReBAC for defining backups.  In addition, "realtime" data will be used to determine when transfers can be done (during office hours) as well as when you are able to use your backup relationship (when swiped in)</p>
        </AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'ReBAC'} onChange={handleChange('ReBAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}>
          ReBAC
          </AccordionSummary>
        <AccordionDetails className="DescText">
          <p>Relationship-Based Access Control (ReBAC) is an authorization model that grants or denies access to resources based on the relationships between users and objects.  The relationships are usually computed ahead of time and stored in a database.  This enables easy look ups of relationships, but will often lead to extra maintenance in order to keep the database up to date.  It will also lead to policy code being split between building the database and using the database.</p>
          <p>Within this application, when ReBAC is in use, the rows visible and the close & transfer actions are based off of relationships (views, ownes, txfr).  In addition a backsup relationship is defined between users, so that users can close accounts of the users they backup.</p>
        </AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'ABAC'} onChange={handleChange('ABAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}>
          ABAC
          </AccordionSummary>
        <AccordionDetails className="DescText">
          <p>Attribute-Based Access Control (ABAC) is an authorization model that grants or denies access to resources based on a set of attributes associated with the user, the resource, and the environment.  ABAC gives the ability to have a finer level of access at the cost of having to provide sources for the attributes.  User attributes can often times be provided through claims in the JWT.</p>
          <p>Within this application, when ABAC is in use, you will see the close action be givin to the "owner" of the account.  Allowing for a finer level of access control.</p>
        </AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'RBAC'} onChange={handleChange('RBAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}> 
          RBAC
        </AccordionSummary>
        <AccordionDetails className="DescText">
          <p>Role-Based Access Control (RBAC) is a method of regulating access to computer systems based on the roles of individual users within an organization.  While RBAC is simple to implement and understand, it will generally lead to "role explosion" as you try to implement granular access.</p>
          <p>Within this application, when RBAC is in use, you will see the close and transfer actions being hidden/shown based on the roles *:admin and *:transfers</p>
        </AccordionDetails>
      </Accordion>
    </div>
  )
  }

  export default PolicyTypes;