<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/555', function () {
    return 'test';
});

Route::get('/resource12', function () {
    return 'resource';
});

Route::get('/about', function () {
    return 'about';
});
