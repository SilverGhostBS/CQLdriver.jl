using Libdl

if Sys.islinux()
    version = "2.11.0"
    const has_driver = !isempty(Libdl.find_library(["libcassandra"]))
    const has_yum = try success(`yum --version`) catch e false end
    const has_apt = try success(`apt-get -v`) && success(`apt-cache -v`) catch e false end

    if has_driver
        println("Cassandra CPP driver already installed.")
    elseif has_yum
        cass_url = "http://downloads.datastax.com/cpp-driver/centos/7/cassandra/v" * version * "/"
        cass_file = "cassandra-cpp-driver-" * version * "-1.el7.centos.x86_64.rpm"
        cass_source = cass_url * cass_file
        cass_target = "/tmp/cassandra-cpp-driver.rpm"
        dl = try success(`wget -O $cass_target $cass_source`) catch e false end
        !dl && error("Unable to download CPP driver.")
        inst = try success(`sudo yum install -y $cass_target`) catch e false end
        !inst && error("Unable to install CPP driver.")
    elseif has_apt
        ubuntu_version = chomp(read(pipeline(`cat /etc/os-release`, `grep -Eo "VERSION_ID=\"[0-9\.]+\""`, `grep -Eo "[^\"]+"`, `grep -E "[0-9.]+"`), String))
        cass_url = "http://downloads.datastax.com/cpp-driver/ubuntu/$(ubuntu_version)/cassandra/v" * version * "/"
        cass_file = "cassandra-cpp-driver_" * version * "-1_amd64.deb"
        cass_source = cass_url * cass_file
        cass_target = "/tmp/cassandra-cpp-driver.deb"
        libuv_inst = success(`sudo apt install libuv1`)
        !libuv_inst && error("Unable to install libuv driver.")
        dl = try success(`wget -O $cass_target $cass_source`) catch e false end
        !dl && error("Unable to download CPP driver.", cass_source)
        inst = try success(`sudo dpkg -i $cass_target`) catch e false end
        !inst && error("Unable to install CPP driver.")
    else
        error("This package requires cassandra-cpp-driver to be installed, but the build system only understands apt and yum.")
    end
elseif Sys.iswindows()
    version = "2.11.0"

    const has_driver = !isempty(Libdl.find_library(["cassandra"]))

    if has_driver
        println("Cassandra CPP driver already installed.")
    else
        using ZipFile
        cass_url = "https://downloads.datastax.com/cpp-driver/windows/cassandra/v" * version * "/"
        if typeof(1) == Int64
            cass_file = "cassandra-cpp-driver-" * version * "-win64-msvc141.zip"
        else
            cass_file = "cassandra-cpp-driver-" * version * "-win32-msvc140.zip"
        end
        cass_source = cass_url * cass_file
        cass_target = tempdir() * "/cassandra-cpp-driver.zip"
        dl = download(cass_source, cass_target)
        rd = ZipFile.Reader(dl)
        for f in rd.files
            if f.name == "bin/cassandra.dll"
                write("C:\\Temp\\cassandra.dll", read(f, String))
            end
        end
    end
else
    error("This package does not support OSX")
end
