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
@IsTest
public class ForceeaServiceTest {

    @IsTest
    private static void getCountable_oneStandard_expectSuccess() {
        String text = 'record';
        Integer count = 1;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('1 record', result, 'getCountable - errors found');
    }

    @IsTest
    private static void getCountable_manyStandard_expectSuccess() {
        String text = 'record';
        Integer count = 2;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('2 records', result, 'getCountable - errors found');
    }

    @IsTest
    private static void getCountable_oneEndsWithS_expectSuccess() {
        String text = 'success';
        Integer count = 1;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('1 success', result, 'getCountable - errors found');
    }

    @IsTest
    private static void getCountable_manyEndsWithS_expectSuccess() {
        String text = 'success';
        Integer count = 2;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('2 successes', result, 'getCountable - errors found');
    }

    @IsTest
    private static void getCountable_oneEndsWithY_expectSuccess() {
        String text = 'entry';
        Integer count = 1;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('1 entry', result, 'getCountable - errors found');
    }

    @IsTest
    private static void getCountable_manyEndsWithY_expectSuccess() {
        String text = 'entry';
        Integer count = 2;

        Test.startTest();
        String result = ForceeaService.getCountable(text, count);
        Test.stopTest();

        System.assertEquals('2 entries', result, 'getCountable - errors found');
    }

}
