<?php


use Simply_Static\Admin_Settings;

if (!class_exists('StaticPress_CLI_Command')) {
    class StaticPress_CLI_Command {

        /**
         * ビルドする
         *
         * ## EXAMPLES
         *
         *     wp simply build
         *
         */
        public function build($args, $assoc_args) {
            // Hello WP=CLI World
            WP_CLI::success('Hello, WP-CLI World!');
            // インスタンスを取得
            $instance = Admin_Settings::get_instance();
            // start_exportを呼び出す
            $instance->start_export_cli();
            WP_CLI::success('Build Start');
        }

        /**
         * 初期設定を行う
         *
         * ## OPTIONS
         *
         * <out_dir>
         * : 出力するディレクトリのパス(/var/www/html/out/)
         * デフォルトは/var/www/html/out/
         */
        public function init($args, $assoc_args) {
            list($out_dir) = $args;
            $options = get_option('simply-static');
            // delivery_methodをlocalに変更
            $options['delivery_method'] = 'local';
            // 出力先設定はlocal_dir
            if (!isset($options['local_dir'])) {
                $options['local_dir'] = '/var/www/html/out/';
            }else{
                $options['local_dir'] = $out_dir;
            }
            // clear_directory_before_exportをtrueに
            $options['clear_directory_before_export'] = true;
            update_option( 'simply-static', $options );
            WP_CLI::success('Init Success');
        }

        /**
         * サブディレクトリ設定を行う
         *
         * ## OPTIONS
         *
         * <dir>
         * : サブディレクトリのパス(/dir)(/sub/dir)
         *
         * ## EXAMPLES
         *
         *     wp simply relative /sub/dir
         *
         */
        public function relative($args, $assoc_args) {
            list($dir) = $args;
            $options = get_option('simply-static');
            // relative_path
            $options['relative_path'] = $dir;
            update_option( 'simply-static', $options );
            WP_CLI::success('Relative Path Set: ' . $dir);
        }

        public function wait($args, $assoc_args) {
            $instance = Admin_Settings::get_instance();
            while ($instance->is_running_cli()) {
                WP_CLI::log('Wait...');
                sleep(1);
            }
            WP_CLI::success('Wait End');
        }
    }
}
