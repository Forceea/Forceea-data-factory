/*
  Forceea data factory (v2.5)
  Copyright (C) 2021 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/

public with sharing class ForceeaAsyncTransaction {

    public Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
    public List<ForceeaService.FObjectAsync> sObjectsToDelete = new List<ForceeaService.FObjectAsync>();
    public Map<String, ForceeaService.FObjectAsync> template = new Map<String, ForceeaService.FObjectAsync>();

    public Integer batchId = 1;
    public Boolean hasPartitioning = true;
    public Boolean isBenchmark = false;
    public Boolean isExcludedOnAsyncDelete = false;
    public Integer jobId = 0;

    public String locality = '';
    public String language = '';

    public Integer numErrors = 0;
    public Integer numJobs = 0;
    public Integer numJobUnitsExecuted = 0; // the iterations that have been inserted in the job
    public Integer numJobUnitsToExecute = 0; // the units that should be executed in the job
    public Integer numTotalJobUnits = 0; // the units that should be executed in the job
    public Integer numMaxUnitsPerBatch = 1; // the max units allowed to be executed per batch
    public Integer numProcessUnitsToExecute = 0; // the total units (iterations/records) that should be executed

    public ForceeaService.OperationType operationType;
    public String partitionFieldValue = '';
    public String processId = '';
    public Long seed = 0;
    public Integer sector = 0;

    public String sObjectApiName = '';
    public Integer sObjectToDeleteIndex = 0;
    public String verbose = '';
}
