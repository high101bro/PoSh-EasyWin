# You can post values to Powershell
# Example: http://localhost:8080/example5.ps1?command=Date
# But we only get content of html files, you can't execute Powershell in them.
$cmd = $PoSHQuery.Command
if ($cmd -eq "Date")
{
	Write-Host (Get-Date)
}
@"
$(Write-Host Hello World Example5!)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Sample Web Site Template - PoSH Server</title>
 
    <meta name="author" content="Your Inspiration Web - Nando [php, xhtml, css], Sara [graphic design]" />
    <meta name="keywords" content="single web page, single page website, single page template, single page layout"
    />
 	<meta name="description" content=""
	/>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    
    <!-- [template css] begin -->
	<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection" />
	<link rel="stylesheet" href="css/960.css" type="text/css" media="screen, projection" />
    <link rel="stylesheet" href="css/print.css" type="text/css" media="print" /> 
    <!--[if IE]>
        <link rel="stylesheet" href="css/ie.css" type="text/css" media="screen, projection" />
    <![endif]-->
    <!-- [template css] end -->
    
    <!-- [favicon] begin -->
    <link rel="shortcut icon" type="image/x-icon" href="favicon.ico" />
	<link rel="icon" type="image/x-icon" href="favicon.ico" />
	<!-- [favicon] end -->
	
	<!-- Some hacks for the dreaded IE6 ;) -->
    <!--[if lt IE 7]>
        <link rel="stylesheet" href="css/ie6.css" type="text/css" media="screen" />
        <script type="text/javascript">
            var clear="images/clear.gif";
        </script>
        <script type="text/javascript" src="js/unitpngfix.js"></script>
    <![endif]-->
    
	<script type="text/javascript" src="js/mootools-yui-compressed.js"></script>
    <script type="text/javascript" src="js/jquery.js"></script> 
    <script type="text/javascript" charset="utf-8">jQuery.noConflict();</script>
    
    <!-- START SCROLL -->
	<script src="js/scroll.js" type="text/javascript"></script>
	<!-- END SCROLL -->
	
	<!-- START CUFON -->
	<script type="text/javascript" src="js/cufon-yui.js"></script>
	<script type="text/javascript" src="js/dustismo_400.font.js"></script>
	<script type="text/javascript">
       Cufon.replace('h1,ul#nav,h2,h4', {
           hover: true,
           fontFamily: 'dustismo' 
       });
    </script>
	<!-- END CUFON -->
	
	<!-- START VALIDATE FORM CONTACT -->
	<script type="text/javascript" src="js/form-contact-validate.js"></script>
	<!-- END VALIDATE FORM CONTACT -->
</head>

<body id="home-page">
	
	<!-- START TOP FADE -->
    <div class="top-bg">&nbsp;</div>
    <!-- END TOP FADE -->
    
    <!-- START BOTTOM FADE -->
    <div class="bottom-bg">&nbsp;</div>
    <!-- END BOTTOM FADE -->
    
    <!-- START HEADER -->
    <div class="container_12">
        
        <!-- START NAVIGATION SECTION -->
        <div class="grid_3 alpha">
        
            <div class="fixed-column">
                
                <!-- START LOGO -->
                <a href="index.htm" title="home page">
                    <img src="images/logo.png" alt="logo" class="logo" />
                </a>
                <!-- END LOGO -->
                
                <!-- START NAV -->
                <ul id="nav">
                    <li><a href="#home-page" title="Home page">home</a></li>
                    <li><a href="#about-page" title="about">about</a></li>
                    <li><a href="#portfolio-page" title="portfolio">portfolio</a></li>
                    <li><a href="#contact-page" title="contatti">contact</a></li>
                </ul>
                <!-- END NAV -->
                
                <!-- START FOLLOW ME -->
                <a href="#" title="follow me on twitter">
                    <img src="images/follow-me.gif" alt="follow-me" class="follow-me" />
                </a>
                <!-- END FOLLOW ME -->
                
                <!-- START SEND ME AN EMAIL -->
                <a href="mailto:info@example.com" title="Send me an email">
                    <img src="images/send-mail.gif" alt="send mail" />
                </a>
                <!-- END SEND ME AN EMAIL -->
                
                <!-- START ADD ME ON SKYPE -->
                <a href="#" title="Add me on Skype">
                    <img src="images/add-on-skype.png" alt="add skype" />
                </a>
                <!-- END ADD ME ON SKYPE -->
                
                <!-- DO NOT REMOVE: START CREDITS -->
                <div class="credits">
                    <!--<a rel="license" href="http://creativecommons.org/licenses/by/2.5/it/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/2.5/it/80x15.png" /></a><br /><span xmlns:dc="http://purl.org/dc/elements/1.1/" property="dc:title">Your Inspiration Folio</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.yourinspirationweb.com" property="cc:attributionName" rel="cc:attributionURL">Your Inspiration Web</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/2.5/it/">Creative Commons Attribuzione 2.5 Italia License</a>.--> powered by
                    <a href="http://www.yourinspirationweb.com/en/free-website-template-present-your-portfolio-online-in-a-single-webpage/" title="The Community of Inspiration Dedicated to Webdesign">
                         YIW
                    </a>
                </div>
                <!-- END CREDITS -->
    
            </div>
        
        </div>
        <!-- END NAVIGATION SECTION -->
        
        <div class="grid_9 omega right-column">
        
            <!-- START HOME PAGE -->
            <div class="home">
                <!--<img src="images/text-home.jpg" alt="contenuto-home" />-->
                <h1>
                    Welcome to <span>PoSH Server!</span> You can use Powershell commands with <span>html</span> codes. Let's get date: <span>$(Get-Date)</span>
                </h1>
                <!--<img src="images/arrow-home.png" alt="arrow" class="arrow" />-->
            </div>
            <div class="home-bottom-bg"></div>
            <!-- END HOME PAGE -->
            
            <!-- START ABOUT PAGE -->
            <a id="about-page"></a>
            
            <div class="about">
                    
                <div class="grid_5 alpha">
                
                    <div class="container-about">
                        <h2>About</h2>
                        
                        <p>
                            In the About page you can insert some information on yourself: title of study, 
							eventual training courses attended, certificates, diplomas.
                        </p>
                        
                        <p>
                            Or you can describe your dreams, your work experiences... in a few words everything 
							that can represent <span>you on the web</span> in a decisive and original way.
                        </p>
                        
                        <p>
                            Insert a small picture or even a <span>cartoon</span> just like the one I have inserted: nowdays illustrations are the trend!
                        </p>
                    </div>
                </div>
                
                <!-- START AVATAR -->
                <div class="grid_4 omega avatar-image">
                    <img src="images/avatar.jpg" alt="avatar" class="avatar" />
                </div>
                <!-- END AVATAR -->
                
                <div class="clear"></div>
            </div>
            <div class="about-bottom-bg"></div>
            <!-- END ABOUT PAGE -->
            
            <!-- START PORTFOLIO PAGE -->
            <a id="portfolio-page"></a>
            
            <div class="portfolio">
            	<div class="grid_4 alpha">
	                <div class="container-portfolio">
	                    <h2>Portfolio</h2>
                    </div>
                </div>
                
                <!-- START PORTFOLIO QUOTE -->
                <div class="grid_4 omega">
                	<div class="portfolio-quote">
                		<h4>I hope you like my work and my work speaks for me.</h4>
                	</div>
                </div>
                <!-- END PORTFOLIO QUOTE -->
                
                <div class="clear"></div>
                
                <div class="container-portfolio">
                    
                    <!-- START THUMB IMAGE -->
                    <div class="photo">
                        <a href="#project01">
                            <img src="images/portfolio/003.big.jpg" height="85" width="85" alt="WordPress Theme" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project02">
                            <img src="images/portfolio/001.big.jpg" height="85" width="85" alt="Asilo nido" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project03">
                            <img src="images/portfolio/002.big.jpg" height="85" width="85" alt="One Page Folio" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project04">
                            <img src="images/portfolio/004.big.jpg" height="85" width="85" alt="Eclectic: Premium WordPress Theme" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project05">
                            <img src="images/portfolio/005.big.jpg" height="85" width="85" alt="Gold: Premium WordPress Theme" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project06">
                            <img src="images/portfolio/006.big.jpg" height="85" width="85" alt="" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project07">
                            <img src="images/portfolio/004.big.jpg" height="85" width="85" alt="" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project08">
                            <img src="images/portfolio/003.big.jpg" height="85" width="85" alt="" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project09">
                            <img src="images/portfolio/001.big.jpg" height="85" width="85" alt="" />
                        </a>
                    </div>
                    
                    <div class="photo">
                        <a href="#project10">
                            <img src="images/portfolio/002.big.jpg" height="85" width="85" alt="Asilo nido" />
                        </a>
                    </div>
                    
                    <div class="clear"></div>
                    <!-- END SMALL IMAGE -->

                </div>
            </div>
            <div class="portfolio-bottom-bg"></div>
            <!-- END PORTFOLIO PAGE -->
            
            <!-- START CONTACT PAGE -->
            <a id="contact-page"></a>
            
            <div class="contact">
            
                <div class="grid_5 alpha">
                    
                    <div class="container-contact">
                        <h2>Contact</h2>
                        
                        <div id="log"></div>
                        
                        <form id="contacts" method="post" action="include/inc_sendmail.php">
                            <fieldset>
                                <input tabindex="1" type="text" id="visitor" name="visitor" value="Name" onfocus="if (this.value=='Name') this.value='';" onblur="if (this.value=='') this.value='Name';" class="text name" />
                                <br />
                                
                                <input tabindex="3" type="text" id="visitormail" name="visitormail" value="E-mail" onfocus="if (this.value=='E-mail') this.value='';" onblur="if (this.value=='') this.value='E-mail';" class="text mail" />
                                <br />
                                
                                <textarea tabindex="4" id="notes" name="notes" cols="30" rows="3" onfocus="if (this.value=='Message') this.value='';" onblur="if (this.value=='') this.value='Message';" class="text message">Message</textarea>
                                <br />

                            	<input class="button" name="Send" value="Send e-mail" type="submit" />
                            	
                        	</fieldset>
                        </form>
                    </div>
                </div>
                
                <div class="grid_4 omega contact-info">
                    <p class="title">Estimates, questions, information?</p>
                    
                    <p>
                        Not hesitate to contact me.<br/>
                         Send the form or contact me on skype.
                    </p>
                    
                    <img src="images/logo.small.gif" alt="logo" class="contact-logo" />
                    
                    <h3>YourInspirationFolio</h3>
                    
                    <address>Arlington Road, 988</address>
                    
                    <p class="right">
                        <span>Tel.</span> 074 5678 678<br/>
                        <span>Fax.</span> 074 5678 678
                    </p>
                </div>
                
                <div class="clear"></div>
            </div>
            
            <div class="contact-bottom-bg"></div>
            <!-- END CONTACT PAGE -->
            
        </div>
        
        <div class="clear"></div>
    </div>
    
	<!--[if IE]>
      <script type="text/javascript"> Cufon.now(); </script>
    <![endif]-->  
</body>
</html>
"@
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUju+CMVs1eNnnhRmFHmC1Fpv3
# FjmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5qyKTehF01/B96/XMOj8HGhumvcwDQYJKoZI
# hvcNAQEBBQAEggEAXWBmp2U/B+/rZghFzQERGOw8m5D2kjyz5HLBqDFiMTMq0CP0
# Xb68lv0QWBQjBlP0SWU19sRs1QtnqsL13UeUAu/vd4WSnhgwqJjpUCx/ifqvrHUU
# h5OcYHeQfsfEwDTGyZ1cFhLl8WkjvkN5y44V5Vn7TqY0hUaofSERMT1WlxF2qhKP
# qltfSb/C9trw6ScTbop0RXCXnRkd8g5TjZBjTLNI/goORAdvyCbFDacMJ44m/iHZ
# cP25Qf2CEeqjUbphBtkQ5xaW4B8LZEtDsRL3r3v+lJjGHVcgbON0s6K3MhEfbmUP
# bR2LgWWcvIKNhdh7husPBstY4rzhmtyKItShrQ==
# SIG # End signature block
