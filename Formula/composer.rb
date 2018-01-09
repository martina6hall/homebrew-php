require File.expand_path("../../Abstract/abstract-php-phar", __FILE__)

class Composer < AbstractPhpPhar
  desc "Dependency Manager for PHP"
  homepage "https://getcomposer.org"
  url "https://getcomposer.org/download/1.6.2/composer.phar"
  sha256 "6ec386528e64186dfe4e3a68a4be57992f931459209fd3d45dde64f5efb25276"
  head "https://getcomposer.org/composer.phar"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "89d8ea984fc8a3d73e3690009b1ee22af967e5dd929b8ebcd27bbd3e1a785f36" => :high_sierra
    sha256 "89d8ea984fc8a3d73e3690009b1ee22af967e5dd929b8ebcd27bbd3e1a785f36" => :sierra
    sha256 "89d8ea984fc8a3d73e3690009b1ee22af967e5dd929b8ebcd27bbd3e1a785f36" => :el_capitan
  end

  depends_on PharRequirement

  test do
    system "#{bin}/composer", "--version"
  end

  # The default behavior is to create a shell script that invokes the phar file.
  # Other tools, at least Ansible, expect the composer executable to be a PHP
  # script, so override this method. See
  # https://github.com/Homebrew/homebrew-php/issues/3590
  def phar_wrapper
    <<-EOS.undent
      #!/usr/bin/env php
      <?php
      array_shift($argv);
      $arg_string = implode(' ', array_map('escapeshellarg', $argv));
      $arg_prefix = preg_match('/--(no-)?ansi/', $arg_string) ? '' : '--ansi ';
      $arg_string = $arg_prefix . $arg_string;
      passthru("/usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off #{libexec}/#{@real_phar_file} $arg_string", $return_var);
      exit($return_var);
    EOS
  end

  def caveats
    <<-EOS
      composer no longer depends on the homebrew php Formulas since the last couple of macOS releases
      contains a php version compatible with composer. If this has been part of your workflow
      previously then please make the appropriate changes and `brew install php71` or other appropriate
      Homebrew PHP version.
    EOS
  end
end
