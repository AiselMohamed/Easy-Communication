import 'package:flutter/material.dart';
import 'color.dart';

class AuthForm extends StatefulWidget {
  final void Function(
      String email,
      String username,
      String password,
      bool isLogin,
      BuildContext ctx,
      ) submitFunction;
  final bool isLoading;

  const AuthForm({Key? key, required this.submitFunction, required this.isLoading}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userName = '';
  String _userEmail = '';
  String _userPassword = '';
  String _selectedCountry = '';
  String _selectedLanguage = '';
  late TextEditingController _countryController;
  late TextEditingController _languageController;

  List<String> countries = [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Antigua and Barbuda",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cabo Verde",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Comoros",
    "Congo",
    "Costa Rica",
    "Côte d'Ivoire",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Eswatini",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Korea, North",
    "Korea, South",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Micronesia",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "North Macedonia",
    "Norway",
    "Oman",
    "Pakistan",
    "Palau",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Vincent and the Grenadines",
    "Samoa",
    "San Marino",
    "Sao Tome and Principe",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "South Sudan",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Suriname",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Timor-Leste",
    "Togo",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Tuvalu",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Zambia",
    "Zimbabwe",
    // Add more countries as needed
  ];

  List<String> languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Arabic",
    "Chinese",
    "Japanese",
    "Korean",
    "Russian",
    "Portuguese",
    "Italian",
    "Dutch",
    "Turkish",
    "Swedish",
    "Greek",
    "Hindi",
    "Bengali",
    "Urdu",
    "Persian",
    "Indonesian",
    "Malay",
    "Thai",
    "Vietnamese",
    "Tagalog",
    "Swahili",
    "Hausa",
    "Yoruba",
    "Zulu",
    "Kurdish",
    "Farsi",
    "Pashto",
    "Tamil",
    "Telugu",
    "Kannada",
    "Malayalam",
    "Punjabi",
    "Gujarati",
    "Marathi",
    "Burmese",
    "Khmer",
    "Lao",
    "Sinhala",
    "Nepali",
    "Tibetan",
    "Bhutanese",
    "Mongolian",
    "Uzbek",
    "Kazakh",
    "Turkmen",
    "Kyrgyz",
    "Georgian",
    "Armenian",
    "Azerbaijani",
    "Kurdish",
    "Hebrew",
    "Yiddish",
    "Maltese",
    "Slovenian",
    "Croatian",
    "Bosnian",
    "Serbian",
    "Montenegrin",
    "Albanian",
    "Macedonian",
    "Bulgarian",
    "Romanian",
    "Hungarian",
    "Finnish",
    "Estonian",
    "Latvian",
    "Lithuanian",
    "Belarusian",
    "Ukrainian",
    "Moldovan",
    "Azerbaijani",
    "Armenian",
    "Turkish",
    "Kurdish",
    "Persian",
    "Pashto",
    "Dari",
    "Tajik",
    "Uzbek",
    "Turkmen",
    "Kyrgyz",
    "Kazakh",
    "Russian",
    "Ukrainian",
    "Belarusian",
    "Polish",
    "Czech",
    "Slovak",
    "Sorbian",
    "Lusatian",
    "Silesian",
    "Lower Sorbian",
    "Upper Sorbian",
    "Lithuanian",
    "Latvian",
    "Estonian",
    "Finnish",
    "Swedish",
    "Norwegian",
    "Danish",
    "Icelandic",
    "Faroese",
  ];


  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _languageController = TextEditingController();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFunction(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _isLogin,
        context,
      );
    }
  }

  void _showCountryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Select Country"),
          children: countries.map((country) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCountry = country;
                  _countryController.text = country;
                  Navigator.of(context).pop();
                });
              },
              child: Text(country),
            );
          }).toList(),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Select Language"),
          children: languages.map((language) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedLanguage = language;
                  _languageController.text = language;
                  Navigator.of(context).pop();
                });
              },
              child: Text(language),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: ValueKey('email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (val) {
                if (val == null || !val.contains('@')) {
                  return 'Enter valid email';
                }
                return null;
              },
              onSaved: (newValue) => _userEmail = newValue!,
            ),
            if (!_isLogin)
              TextFormField(
                key: ValueKey('username'),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.length < 4) {
                    return 'Enter username 4 characters or more';
                  }
                  return null;
                },
                onSaved: (newValue) => _userName = newValue!,
              ),
            if (!_isLogin)
              TextFormField(
                controller: _countryController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: _showCountryDialog,
                  ),
                ),
                onTap: _showCountryDialog,
              ),
            if (!_isLogin)
              TextFormField(
                controller: _languageController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Language',
                  prefixIcon: Icon(Icons.language),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: _showLanguageDialog,
                  ),
                ),
                onTap: _showLanguageDialog,
              ),
            TextFormField(
              key: ValueKey('password'),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (val) {
                if (val == null || val.length < 7) {
                  return 'Enter password 7 characters or more';
                }
                return null;
              },
              onSaved: (newValue) => _userPassword = newValue!,
            ),
            SizedBox(height: 20),
            if (widget.isLoading)
              CircularProgressIndicator(),
            if (!widget.isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _validateForm,
                  child: Text(
                    _isLogin ? 'Login' : 'Signup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? 'Create new account' : 'I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
