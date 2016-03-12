name             'vlg-crucible'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures vlg-crucible'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "java", ">=1.36"
depends "ark"
depends "postgresql"
depends "apache2"
depends "database"
