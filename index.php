<?php

$msg = 'Rejoice, for it has been released unto us!';
$days = ceil((strtotime("2010-07-11") - time())/24/60/60);
if ($days > 0)
{
    $msg = "<big>$days</big> days 'til the North American release.";
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head><title>DQ9 Countdown</title></head>
<body>

<div style="text-align: center">
    <img src="dq9.png" alt="Dragon Quest IX: Sentinels of the Starry Skies" />
    <h2><?php echo $msg ?></h2>
</div>

</body>
</html>
