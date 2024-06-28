<?php
require_once 'vendor/autoload.php';

use Stichoza\GoogleTranslate\GoogleTranslate;


 $tr = new GoogleTranslate(); // Translates to 'en' from auto-detected language by default
$tr->setSource('en'); // Translat $tr->setSource(); // Detect language automatically
$tr->setTarget('en'); // Translate to Georgian
echo $tr->translate('Hello World!');
$lang=['ar'=>'arabic','en'=>'english'];


