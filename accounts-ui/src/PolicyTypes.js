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
        <AccordionDetails className="DescText">this is PBAC</AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'ReBAC'} onChange={handleChange('ReBAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}>
          ReBAC
          </AccordionSummary>
        <AccordionDetails className="DescText">this is ReBAC</AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'ABAC'} onChange={handleChange('ABAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}>
          ABAC
          </AccordionSummary>
        <AccordionDetails className="DescText">this is ABAC</AccordionDetails>
      </Accordion>
      <Accordion expanded={expanded === 'RBAC'} onChange={handleChange('RBAC')}>
        <AccordionSummary expandIcon={<ArrowDropDownIcon />}> 
          RBAC
        </AccordionSummary>
        <AccordionDetails className="DescText">this is RBAC</AccordionDetails>
      </Accordion>
    </div>
  )
  }

  export default PolicyTypes;