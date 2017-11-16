ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.1
docker tag hyperledger/composer-playground:0.15.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Z �=�r��r�Mr�A��)U*�}��V��$$Ey�,x-�o�%�G;�$D�q!E9:�O8U���F�!���@^33 I��E2%ڻfW٤fzzz.=���3T��̀l�;������J����p�Q�|�c��$��#>,pa>&DD��G�X������X64xd���Z����J��LK5��%l1��̮*#k�a �愹����t�:2�u�F;�\���a�5�djHi 34��M)��1L�rI [��6�C�ۢiH益���n������r�t�<,dr���� ���V��b�;��x�0��l�@b�����Ŀ����pO`4�!SRڪ��)�t��4Ұ2�Md����J��N�+�!ڦ�(�6,P�d�:�\ܙ���\O��⹡#�ƝvduUC�;X�����a�T�y�W�%�j�v���0���A�r�(ظ�W[����B�c��mä����F�i
'4<��
5kn�j�0���3L�x�-��=:��a�av�PȣD����i�N��p������I1��;�H탎$�)ն:�)sh6�|�h�<_l)����mwp�e40�����Dd0?����u3d��{_}p�eWK�a&Թ�-�7݇4QO��R�ܹۂ���;�v�zD�ё�3��WT������F���^2�w�{���ޅ?�+p@A� ���<�{Dɋ�"��?C�/��'��#�wN��W��Ma5���������A�?2{�yA��/�y���?&
�Z�_<�C������e8�� ���
�PT�����ǄT�;/VK��[��5����@���o�s̀X����+^K�0E��������E��
X���S�+��FC�Bk�-w��
�����Z��n�"�(�`/,C��:��_�����O��QQ��
 N�����d�$�G��\0�N�f��A&(�4� =k�.[P7L�kB��!NqlvZ6�8&��x�vL���"L�6D�L��U�0�Co����Pm���wZ;��i:5��
M=��C���<�9�X��MÜ�9'�.�*#ݢuKXj�( x�h�L��i�˒���5͐[r���eh�P�0B�����֨�5GՔ 4�ڥGl��:  ����d�,ƣF��N����*��$�����xp�6���ƕ�f�Aq�iw���z9�A\"H�����zg�a��GҴ=^�\��	8wR���翫���<D�uG��y�nB�TMPW���F�DLG�U�1:��a!�6:O�1���|��):|xƨu�h�G<� ��X�IH�x�@r� �>��І�ڛ�� � �!<aC޹�W�Rf�*�\��kf�^"�T�j�6�A�N�&��v���5zJnh��$�=��>;1�a�8�o�w��cX%�v	d�~L�ʼ���2�T7lp�EfڮN��`|�zTy �3�е>�_�z���qLa��<VH��#�䊎j�B�w��_�vw����û쑆����4$۠�T�&0�f^�q�Z�O��? �و�z����,��}�x��:Pu2l��?c��%f� UnR��Q�dϨ8������˗#ĉ���n׼�Y����Хj{�Ȃ2�:Zo�_+L���D�7�/�����hx����������h,祈�ϋBtR�yn��Y	�zRj�q�3��@}4S4=�����2D�͚���h�ix��ʏa��T���	�	S�˕���R�^��W�c���glm~�!_o�����JnFJ�r���t��;,<��i͞�;� T8���XG��6������$p����
�Yh6ML�X[��Y�Yb���\�J��J.�>�Vfs=�6�w>�Z�b=�ф�һ|�mQM���Ƿ\ ���&����}6�V��'�i"��=Z$T����(`M�iאɂW?/�V
xR��ɂ�Nv��׭x���w͆��s����i�Q��Y�~E{���%�E�.�,�����	[��+�����UM�pXIӉH��:x��y
��Ft� 	r xָ��M?�_��>0L���iߧ�H��<7�����Z�W�/�̓OU���6Pu< ��:��K0��1�!��־�:��)�?�0-_���c\4���^,j�,5����'�4,�������n;��\
X���b�	�?��������o��ᆎ�pӲ2M�|:���ށh�u�
2��.��Mκh<
�昈�Jɽ�_��ڿ�w?�O�ɖ��M��(�g�ăEr��e�6 AF�{Z��D/2S�7���Q��V<�'R��x��3s+d�"��w��2�H����'f�:������V-V����	��=�<�1��W�.���ce��?�8s&��{��N��5�>l��F��@��*�on��/s)d��'����^�W˯�����Us����ㅈذᮥ���N9� ��d�@��?ԛ����� |����ex'l�ݻ��ߩÑ�Jm�����/s)d��cY���D!���V�����9�s��O����o�{�j�`�!�CXq��y���q�������^��|'R��@`@�� �@ [1����O|�wu��GC�6�w�����|�\[e�4�/@u�NN��B�P�Z����[`Dnx�E5Uˍ�(|�J�c��͆=��*3$��Y@H!�fM�E�<���$)_$�Acz�a�O��j o��i�u�������O }��@�nw��:�z����}��f��^��GR>�a�`�nը��e�Ϝx�Qxϖx�L>2VFd_���{�bʋOM}�c����9�=�1V����x�&����w�O_�}�f�{-��f׆�f�83�Q)w,U��������<�� M]m��E0M��W��E�&�9DW�Bt���F&f,��l���x^��ơX�V���v�ۮo�Q]k�r\8����a��!����0E1;�ZL2]���kKm�DVf!Hf���4(`���hx����� _��Վ�U����)��8���t�K.8#  ��F���PM�f��M�|
�Wti��L�$�Lp��i�¢Rx�l��K�@2�R��WJ	o+x�F�W5RX��0�n;����2A��쿈8�%����[	|���8�n�VM��	�?�b�)>��[���/x�����iAA�E'�_�	��_+�e��a�»x�C?NE���F������?����eH|�4�nav�4�*#w�, W8�a�հ���4xM�Q���1��v�6�$���׸I��%Ƶ=��Xl���E6G��&�H�ug�2<+�uc�z	��5��������`���:�����|����?Vw��"�.OA�rQd����Eb���Hx��`��[�y�ݷ���������b�~b���g�q�(
����˼��Z]����h�D!��#1*�k�(C1���Zl;"Զ#��������$�i�_���:�x��"��l|��%��6}��0IC��V���?n��1��F����7�f�ȿ��7#:,����t�������b���{�d��������O�1���8%D�M}8^� �G��v��w���O5�;�q��?̭����'���Sz�:�����#��z�_|�l,�HSCUp����
9ex��:�T�>���ܛ?m1���|d�ه�7r���e٣\�:����Bb��t6W �|"��%�J�����\2{�LJr�!�r	��+I�P?.<�+�D�o���F��{��in�8�]]pi�ۓ������J|5�h�������TJ4
ǘT%�*4kY�]�v�I�2s!U�<��:�yj"�N���TЮN���lEz�b�t6�?�J;go��ڛ�uV�\��r/%A'_I��;��=��ה���+\�|%�Vr�	I��i� �~r���V/Y<M��t��q�*]��#�K&��E!c����܎tN+�|���2_x�W���K��OO"�M�v���Őz���IɆ'	���/G4���r�R;h��J��d"�M�?d�y1.5��d���K�I\NJd����D�϶.˕��qЍި��';���pR��N�����V��Oᾴ��JYU#��Y��Kmʱ��W�J�31��6z��J� /�x,0�J��N�zE2�{���'}�W�'��vZ���|�"�Rr�b+�ܗr��y�X"������A�����ic	���C�Kf�yUx�ó��Kưex�א��j2WL��~1�NO�j�S$nëx�$j�g�c�\���j�8�M*�F�Q��G�v�u_12F�ӹ^>s���7���#ȩ���u�B�$����ORSĀ��������q��Zc|�?��'>�^�8��rx�?x ~�`����a��[��+�O���]��i����5�h������0ϯ��V>=�� ��S�����{xO���щ,׃D�*��$�5W[��c��P:���TȞhZWˤ�|U�/���*WR�Jf7i��R'_m]e`2���Xl'5�y53�q��/�"�HFC���U��^5�r( �R(Uu���
��(�o��cf���l����/����D�^P���Ea���		Y��
`���,k&1�ZI̲F����,k"1�ZH̲��}�,k1�ZG̲�3�6bf�F�򘾻��a��7�����[|6�ϩ}�їa�	��������_5q�K�ͿL����yz]R*u��T�Sņ�����Τ���y��<i8!�G�x�?f���Y&�J#�)��q�3�x�0$������l�n��Q�?���%���J����߀���s��o>A�}�b�}��ֱ@��7�G���X<I��7i\|.���� �4�H�J��%�<!Q�G�7��go�Y^]E����È��L�=t#P͆ł H����4b֨���ѵ,І:l���^�*��>xq�,��!?-}��	=��� �#أ Hm��;�_K��nB�-w�LG���rEzԐf�h*Yj�}5�L=7���o���a��/�{s��'򠽷��$��A��������A'o������=}�~U'�,�=
�I�:���aMs�B�$�M�ɏ����L'�@�pL���Q;&�WA �Л��G0�A�>�L^[� �}�F/\it)xth��@P�4a�TH1_��"�N�=`��'u[��>F�{�[��x��dB� xZB��@�I���AEP^ ��{/dЃ>:I�g��΍���޳�8�d53;Eΰ;�w>4��0ߚn;��b[�Lg�N���t�l�Hg:����L;m�5��#���� n �!�����
����!n�""?N�\����]��V��Ȉ�����U1� �Ǹ-H@��l�{�n{0�&�y����� 7T6W��c�h��̰?ugG�|�1bW>����C��?��\L~�x�J ^l]k��ñ�c;�]�Ơ>����K A�������!�\5���C�v{���	���;)ƒ܇)���p��q��N���pn�џ\+������:W�nā��l������xw��v������@(D#��e%��$���]��7W��#h��E*1Ls?���^�y_�wK��ə�����ѮcΠ�[����u�Z�%!�.��k7�G�+����~�����r]W �dOg=ׁ&���9���	VLH�o�n�\f�����Tz�̂Ty��<�*)�����t7��h�T�l�w�/��ƽ��!P	�1�z=���3C��E�s�G��v�y+�ԍ���L	k��ܭ���>~�
h�?�9<4�;rjY8��]���@��P$[I��wy
�1PLa�����wwk��YD���������� �W�q���J�c���M����\b�>/|���e�������O�*�7<��F�o��������O�%��E|�"�į������_��!�+�:�]L��'�N�♸��Hĕt*�R�X<���8�US�TL��d����j2�P4��L�V��K��#�#�~������?���g����t�T?O����L"�#���V,�o��oQX��~;�ݷw]����[���]������=�+b���{�/�E���Ӟ}s��^�4t�1x��#��Ε�� �i�F)[T��Y�a9�մ���Z��9�]��c�g���1:;�l�-<�ό��Ț���B�:4?#vgdԼ[TV-�u�Y=)�uL[�i� ���"�bJ��zGb�cIl��vM��	�i/&�Qv)�����8y�+�%�.$�Ƹ4�G�I�������;8��`a�{���8�iS�\h�:t��S�p����N3�;�6��a��R���ց�:*-ّR>D�Q��&mG:�L�#jeWB�����L�Z��Ń�LV�|eޤΝ�Zh�R0cr *}1s8��F��ԋQ��s�F"��G�%8>"�)l�`���%7s�a������3�z���V �q��x�H��Lb����薒��L��u��\�;�a09Ol_p��Zn9=��3�� ^mb���Ձ^n���$����Y�gZN(��V2��f�n0�q��O�T]���0Q%����̱Ռ^qv����R���F%���Jد�6�y}&S���P�;����'�Ȳg+*U�tcF#7^^;�E�1p!���bE ��eD��b�֢�@��v�'�a�=�����?�/N�U-5��ti_�t��KU⶞V�li��m�"+�E�'%F?'bz[H%�-��6C��N�mN���������ӈ�t�d�9&��"��+��I���D�
���C�Ҋ�r���s��)3�y"[���ϦTj�HjI�j�-�ɏ;m-�/�q����Ü����̜3*�!���ѱ�ju[�i�F(�>��~?7�gR#�
*.�F����G~a���;���k��+{/�������@l}���%�{�7+��6��/���S�i�e���{_���m��N����k���^��b��Hd����+���\V,������މ��׉�!W�G_��'���G�"߿��{�{���ײ��
�2�e�`g�U����^V�t�$��{d>�����sLӗ�9z��{N�e,�$�c�E�Fk���9q�9̹�u�^�X�cos��m����oXC!��Җ��z��ص�Y�A����n7�uvE��Y*�*p���?��T-ў)�U��b��)�X��z)&7�՞5)8���`�L��:�K�.LJ�&�q����\&�e<ˠ�s$N��j}g8��X�A̴sN��l�2��,�t��/��i�sȁK��o��6#t�+���Z��p,��~�.����LI��htL�$�$��T��Œr�n��-�G@%D�1�Yu�OE�X$��;���Y)�	�ьN�Bz0�J���k�&�e9P��RTZ��8+��L�ji�AcuA�O���o�����򶂜_1Ǿ�̍*_>U��N��"�YV��e�.+�	�7�Ҝ�3��;q[z�ɝ�:������Pn�z�f"�/!W���L�-����s�r��,iV9�r��V�уa[��&j{�r	�m�U��4F�,W�u�ƌ3z�l�V�T�s^����C����8��̻�rNd��%�36Ww��ڣ��4�z-!h��b���A�=8?�k:��4�:��\�$^�M�Q�fG��LM-t��R�=�Zʄ/5������3�]�/.	��I�L�X�sE]��L�7^:6���a)F�h)WO��Ҫ��t⿼�&*$˵ +�Q}2>��3�ʲee ���đ��+HL��x�d���G����Xp�0!n��b�_)L \��¤��y_��5���Y����Qnr`��f�'j�#�=�S�N�����tfޭ7��W҄�mv*�$k��J�h���A!n�2��NdV�)�(�(�/Qv�t�ܑ��l�|�r�J5��S�J�h��<8S�E��C����
K�z3�RZ���ˋ�T��LWbNN��3	�N���<�+LVoE�4���dGdS���u�(�0�R��kg�UΨ�WS����z�G�oB�~H/�j䍰�����e�k��ƅ���{�.�P-{���b�=?��_&~��ckfIˉy3��ef�e��ؽAS_���"��o>y�z��2��M��Gr�E�y�x�^{������0���+��/��ބ��J��ěE`����	FH�'<�������W���8gS<t{�����MorE����Z�d�>�g�>J�/]��XFe�x�����2�-���=�����/~�9������$�ċ���܍�/�F�=��O���i�����}�ްt�Z�CVIG�S�̌��a��Y�)��	���jcw����vME&x���}���zd�g؄)�����?�'}��uz���C���ZUX6BWl�%�8~���	ކ�Y7�\<l���Z=C� �+bw4�pG�A���Cz{���+�n�&A���p\
[��E�!d��a�a`��c,d��Z"�"��TŅz��E�Y����7�T�f�.��]�70&��H�p�#lㅳx�NHR�Ik`���Pf�N!�.���_���%�l�`�/H�kk5l[e��!K85�� ��H��E-O�7�p�p�������lc�[W�>԰Q�\5�	6V�s}j����̆�>j\��!օ"5b�hC&~`������ �ON�����5��?'�x]�+XA%� sA���t̠�h:[�r��
,�N�#�A�qX/z�D�L 醵�>��`�By���zR5�'r:��D�c⚁�A�=�u�qǙƽ�9E��8�{�W��������Ż�~�A�i~	_ ����}�k��>�afc��C��,:=�Tl=���{�kX���M�g�Fb�7?1$X��C]��\�C܋���-�S3�%%�Iw��IB���t������EP�M �P?[�-fN1��Üֻ�5UlٺV��Fڸ�R����	
/�D����@d��"*��le��Pρn��1`I�x�K�c���!��kv�U�ր��uK�5%< /[x��Ż�������'f:0����G��H�RFe1��^�!I[���F
ҳ���4�-��l2��a��(�'x�ؐ(`A�nٰ��,��l��v�NG�+�~6�z����!�µ12����Zvi�Av��O�X��r�'���[�Y ���T얲n�a�,Ϋ��U�͐"n]k_�b�V�&��g�>���7Eal(8]6�����jĖ�Q!ф�m �h�[l=Ag���h���#D'���٩9D�6ǻ�]�yH�}�K ;D�^(+�R��C�S��qc���M����4E���?�0��kN���F~Mt�m�.�T���#��L��[��[芃�3�U�1�C�olj�Ϝ9n���{>� ����"����]Mv��7�������C�][�5���iz;�s2�����{�2������ 
�=W+�s��8�����̡���u�aB�4ǜ��H���݋���䎂M�q�7з
A�h,��U���Y^(ߠ�����`�WVt�w��@�
�Ǔ)�@N���
�q5��R�^O�SJ�O@�q�?K+r_�gS �Ȩ�N�{����(f�y�ܠV:@�\?�n���`
v��]�i/vLH0`.̡�|:�Tȩ$�e9����
P(ZM�b  H�Y5ˤ2j�

!�p$3Y5�V)�*���;ğ�|����Po���z���{ zx��xS���<u����b�q׺`g���X���ȶ�����_�L��\-��c��HQ�vy6�)���|��(���إ��ߦ�y�X���k��&/���kWt*ǔ�fM���Ǯˍ"^h
��0�WA ���+�S��D͉�L�������ۃ��q��\m��b��%��n܁�.j_DS�6�=嶝&0�� \�u{�`��7Hv���)��<*t3|�U<B�P)��x�����}���\�[�ti���Va3�x�W�ZU�H�fc}q�F�=��L����ӭZa��%Q�#��=
������[K�m㪹#X�XmJ�j%/N+�Ԯ6�DػG>��/�nV�A:���L0Յ^c��E�A�e=	<W�e�
-�?9FbX��?ʙ�ހc�ȟ��rE���������+�a2�I<S��r�<�Fߙ|���^B���$�x�8��eD ��&N}y�����{���ȶ������b?&��
~��+�D+���`p�V[��C	Č|��-��|W��6�ٚq�k$���8���(�*���Bё���NQ��n������,Z�=]��D2F����<�/9�itGO=������������_�ѷ��8�J������D��NR��^��~��ӿmX=p���/��c�L�Ƕ5<�S�9��fp"�:@	�h59�!z�@���`�+�Y�t��v��7�p�� ���v# �����4�?p��"_�?'���(@��O��vI���ӂJ����/�u������	��6���_������������	��_I�5
�ŤH�1����Rd�.�#?��
c^$�2��+��K������t~np��������������$����Ŭ6I7y�ٮ��ckO�F�پ޲��2������Y�;�N��r�sܨ[�=?��A�fzkz�6C&�;��#���g��a���3�O�_N��R5n{�8$��a�j�#�����O7�|W_i�>���uw�xp��C��:>^��{C�~��cP\����)
��(�A�i�A���G*��Fo`�/����_�����������O���Ԯ�-�Ԁ���W���p������i��Y"����W����<�?
����=���.Qt�����di�^�y��� �ꄣ:��u�O�����B�0���e@����������##����
�!����O
��"��߹������O�t�8�嫶Ԋ�l1,���ϲ����R�/���'�3�����e�{��6�I�o��(��'�j�~~�����'�th��*��\f5�4�eu��z������t��T��sc��V�*��F�����2 �e�a�\j_��f�_������>_�>���l��j/dzҢs�8���~Mxm��oY�����3�,g�ݞ��ܧz9,��"W���X9q��W��ΐ?Ԓ�fQ�MK�sLT�9Y�C��Ocw����F�O��t���`�x���G�[�ݒX�?��W��i@R � ����X�?��+/��-Q��"������ ��`����O�������,M���* ������l�]�9�`�������C�����f����_������i.�x�4�U����o\�od�����	�o<�X��z��~��>���񬯮�d�ξ�6\����8 ;L�7��T��V�C1��RKI7�֘��ݩrvd�67}޶-={
뉿���l��S\�?���,�sH�PT�0������K�{�����c.�lJ�J�0I��%Oobmo��5��(v�i�MҕS�;83|q�HuVQF�����4���"CR/'mG�hmO��@��,����Q��P���[Ɨ,�b�+ �����p���g�i�������G���GE!�S'r+r$'IAL�l B�a����!�!Ʉ|�1�1	g�88��������W���ʎg.Ω���u�'�m&��tޭe�Ɯ�֢aM�I�T���wD1r7'�??��8�<I7�uw��]���;�a99��S����F���%Y���6����%�F���pI3?n�gÏZ���{����?�������o��p����:����������q�~3>!8�?���+㿣�胣��N�q"$.q��3^�I�p�9��f�y��s�l{|����w������ۗ�oK;�����>'f����z�Xr���$c��V���eU(�ٱ6p��/��7vt�4�� �8���<��4�+����~���� �_0�U0��_0��_���Wm�<``�������?�����������^��MU���z"t����yz��?ZT���������M?#�nk�3g O�� �_���3 �V5l�V�B~�T��! o� ;�ٖ�M�^��[�,�zI.�Ì��u�lF��Y���o�eH��?��D֣���m?�깐��{s��7�E��x�7N���۞��׫�� p����k<pP��\�'!/����.�˭z��b�y)Z Re~h�J�&C�I�q�����R��	Ǚ[JMml��71�Ǘ�V	e�����B����G&i��F]���2Tjө�R�t:ӌΆ���~��E�#��"�걻�.*�˫|��Z�8�[c�HΊM�Ǘ�m�g2ރ8�?�}��X�(����C�����o�����N ��8������`�	H�v�a*������@C������a�?���v������Q��Ɋ��E�lH����<�J�@��3~�N����D)f���y?������A��S��������^78.Kc7��7�	.��HVϚ]�s{?bK޶ح��_�ݾLv�޻�n�.���hz�q�O��Ol֌�ݥ��0钴>w���eē�])�>��ǖ5�Rg|P%�k]�Y7���{���O�����>^�o+�~���@q�ߑ��i��(�B����?��!����:��8��_����]����\��ۏ��r0&������P��C����o��P���m���]�Du�y�N�t�/W�]�wXV�����K��N�s�gz�o�?��}+e���]cg���1'?�T+�f�w�(�gš�˳;�F��I�'��/����ĸ?h+�Mg9	��p6�M�l�����%x��+4�v#��^��X��L
s1(Kf�ĭ��=�z�]�V�}G;��>x�QPE"�β0���ڍC��v��୔ns-����]ىl�C�pT63�P�d�1+��č��|����bw3#�F��H\��k�}������u��$�������dzQYI8E��/cݖ������������������8�?M1���"��?4������o���H��o����o����?�����*� �@��������@��O?B ��������Q �a�/������������P����cv��U�N�1(��{��$��4I����?
P����-T�?����WE���!*���r�����G��!*���r�����H�K�a9jP����`a�`���������G�����?����?���B�����D`��0R8����?0��	���?���� ���?XQ!�n����C��2��X�,�������� �`���6���`�#0�Y�@�U@��������������H�J���98����_���������
,����Q��P���[Ɨ,�b�+ �����p���g�@N�OQW3���32D�g��B6C����*��dȰd�S��K%���,'�/��O�����������7F���L}��7[׈S��Ti���8NB�F��(�6�K�2�	�+�H���vs�Z�V-˾�l��/۪,�'5s�vg�e�W�Z9b��j[�`G����s�����E7�D��7���8��1�r]/�5 �u�X�~��^T�o8f�p�����Q��?_AշRp��C�WX�?��T���w����U��������_/d,�\˻��Qۘ;"�uf��Z���߼���w�/�N��_�A��ݣ���:ۭ��anD��9�ɜ$���7��L�ƾ>����o����ܔ���������ɘ�Q�o�����}/x������/"0������w|o�����_��_0��_0������V���e��������O����?��1�X=�w�d���$N����F���߳��Y;M��I��cH|ώ?f���AX�i����Y�5�	٢X"҂�85ZY�]�D5;ɘ'�;6�~b.��\����1�m_�N��ؒ�w��Y�mA�{�q�坾��{�t���6��R�����������E�9,Х}�UO�^l7O#ED���X)׉!��=�2n7�١�����;����p/i��BS�d0��_?����s�f��(՚��gʩb�'Cm���5�(Y��Z$��6ٵ&\->�e}��q�����;+���=D���-������/)PP�E�G\��|���g(�?p��(���O��F�G��6�A�����?��,IѠ�(�A�i�������(@���{=a�~�����!����WM��
����U������}Z;��$�%)�h�3�]��_���������~],��猛v�U/����s?�f��#�{��Kʏ���s
=�R�-�שK�R���e����e.o[K���-䁒�_2���5�j)Jqk�s���BS��2~��t�Ǚ��Z�z�\�t5�gcZ<y�k$�^�;�_ɒ;�뜒w(�_��ѼɬJ�xJ	����XLr��D+>��o������^�BI���gY�{/i?��Ƀ�CN�n�O��HK�TQaؙ�LMq����c��m
'i��-��-b�jb�Vk�*˜�-YSt9U�y'uE�J�6��#�E�����D:��Ӛ`W4S[�����R��)y��Aa)�9wJ�����</KnW[u��7���������/"��?!�Ȁ�?f"�Ҿ4cBʿ>��4#��͟��B�e���r!��dHE0��Q�����_���C¯����d&���h��`���E��(����1n������{J����ޮ�խ�+7�����G�o��w�8R��
p�����?��!��2����������8�Hx+��)o�?�k����Sw��JO_l]�O�h������_X4�4������%؈������?���������M,e������^�~����&�ݖ��T�%y�o״]/n,B�{��dFҚ��k���Z�&{^j�C^V�Af�f��=V��ٸ���$5v��-�G�7����#���@/ש"דTΚ5uT��on����/ڴ�n�c٘.K�$���t_��I3����kmVS۲��vn����f�v��*@@��~tu���(������hNvr���Jb �2֘k�9����#�\N�q�ba��v��r�H=>kSk�<,�VM�9װɕQ����X^($���U��2c/�q����[�?P��
R��)��Iݠ�e+�e�Hf�t:~E1�aj��jY-c�=��2N*�S��\)���"������J��ߠ��?s�O��kO�H��Cg�*��XՋ��X5j��=м^s����.[Ղ��l���⭟��������i �/V{�����x�դ�Vx�%���������)�����r���������! �Oߚ�������ݩ���p�m���h���]�?x?��a����C��u�;���X]�싉�i��#'ՁPjV���B8���ck�����m�Oۢ�Bh\f������\!�KW.����5����ƫ]Wz�����ᤔN�y8c��-u�it��v�Ѭ�uݾ�j�����=c|�U�z#�E����S�����-;�b��Z,ݟn[��ܰ�2�&����?�M����y��w#y�Z���Im�n��-�v�[+sWd���n�rS��n��KJ�ʪ���וm�������1���Pj��`8�����+�r�V���P;�z�a��,K5�\�5G���c
���/ǈߥ6e��+�7�i�A�������T�F������߷�����O�!M��D��!��u�'S���T ����	����	����ު���!�\����y����)�?������������S������������{�����W�w	�����?�'1���A.�����ϔ��_��C�� ��g��7�a�7d��ɸ`�� ��Ϟ�	�*��J	Y�?�Bd�����������r������������?R�?���?�/r����P��
��P�= ��o���/]�?@�GJ��CEHv�E���@b���������`��_��|!������r��0��r����r�_�?��?���� �� ��l��o�?��O*�R���������������|�?��g�\����� ���!��~����0����K��߀�?;@���/�_¯�X�!%��u��q��̜R�
I0�\3+�A�:7Ke�0����$���VQ�=i`�)�M}����#�_�����O/��NO�aQ�.L/�Tc-�mrM�;n�~�����x��u$�8	��dl�۵h��6�S��U�〟"�آU���	��V	��{#+�c�&o��d�z�t�v� ��tX$��vXЙ��$>Z"-ޘ+$�G鞪p��5�ݎ%
!���4sK��z�U�ͣ\o*K��)�s�wuSY7xΐ���?�CV���Y�< �?��!��?�!K�?�Cf�
��<�?���g��j5	i'�:��p1�bT��,k5m��.;kڿ�ua�l�[��r�����m�����8��~U*���i�J:���ù�r"�8��r�](cW�Kɷ���b�����G�_��ߌ�e�����+6�_������� �_P��_P��?��2��!r��(�Z��@���o��=����k�����ڨ=�8r$��3�/����O�ϗX�Dn&ា�Ё����6��h��,����]
èvwv����h���I�)s�a\��Ѹ�e̜#��ƫĒl#L֝:���ms�ν��Uw�rP?�J�/�*�m��Y������RD6Uv����C��5Y>g	"�ի�e
є��Z�W�G-88�Q,�|��榠TY�z��{)���O�5��:���S���.�w%]l��
�R�o���:e�Ɓ���P�Y,�A�l|_L��7�Cm�HM�h:j���k���~y��y�8�OY���� �#�H�����v��Qb����x{����_�H���^����>!{ ��g���7=�O���L�?)˺�������?~���RA���b������9��7�? �7���2}�������?	�i ����������_�� s�+@f
���[���a��̐���3A.�������T����SR��>��ay����ǖ��&��ԯ�?�A��z$v��?"��#)�@~��w�X��|�gj?������&7����/u����uu�ݒ�k]5fG�R�zC\t�
�!������[�5&k�Z�Yc��S�u��ך�����es|��E�rdO%e�ȏ��^�~�u��&��Ǣ��M�ȏ���f����X����=f����֑�u��31���D���=\�G860&���y~ka��v��r�H=>kSk�<,�VM�9װɕQ����X^($���U��2c/�g� ���3C����"�Y��=���������y��Ǘ0
�*r�����`�?������e��0��2�ϋ�g�w	���[���)�?#��o o�\�������W�I���Ge;��kv�W*���5hN�����h����(����Dk��{+}=:^��� y�ϧ��>؊���';n]%�zY��:J3E���v�)���^hL�o("��M��iг�����x��訽����"c��� $)�35 HR�G5 ���z�l�뫢]<����.�!Ѯ�̷�( ��T�nk�U�./sTPY���P���P�^�;���04�.j��"�v�0������X���RA����"�Y��}����y��~��������d�dt�Ę&��j����&�i4��aV�����`�I���F��s������WF��������~���f���-k���cN�H�N���Q�Lf��b.EcV���?���fB���U�=_��jy'��Y��
���ٞUR��~?W�S�!��Ӱ���AN�q�E�4}���c[t�	���Z�����i��,�u�9���C��r�����2���E �00릸K��!��?3��ƻ��^�ZGR8t�!UtI���r��F(������	��K�G��#����yU��ع�
�#�QS���`��Ո:?��Ӯ��=�ے��.����jx�u�
���%	��^�|��W�_T�����#��_Wa����/���P��_P��_0��/��Ѐ� ���J��2·��8�������cw�1Q��-��p��W)�y��T�3�ߏ�  �� ^� �V�SWnU�[��+*f����N���-�J��SY�%}1+3ᑦ�`�Km�X�'Jm�u/P�^�[�6�Z������C�ǩlT�>�<��^�z4���Fɘ` �ݡ�EM��z�V����D|��5�{��CM)2���mnJa0aiJ�U9,B��{_�F�?��l��t��\HO�ڧ}�g��|a�x�i�R������$�gF�ɵ��C���fǖ907�l���B�>Xz%l�����Pl�^�Y��pJ��Ҵ����w󿽉�sV���>���������	�.1��i�ܝ[�[����O��o�w�Gu3����aAd����E�c��~{�W��q�!9��ߘ��(�O���Y*H��NP��م�.�V}Yx����`��?hɎ?>#o��k�.��}#������˓���/�py-W��O[����1^��'OI(>�y����o���4�<���� �$�������@5�E55��o�����[0?��o�<�qÂ�Z%O�Zu��aჱ��S5BC�wǏ���������o�ڹ�:�����3K��B�(�;�7���?>z���������y!�'����w��ͱ���~{�������w��|W���^4�_�gEΟ�>��0�	#y��Ouკ�!>���{�Ϗy8�W��"�'�f�>̓�Ը	͍_�=�_s���'�n
�R|���j|��yn��1��;�u\���������,8A�3
�so��rSh���J��Orwk���1t{Sx��[���+��7��3����'v<�s|�^���6�����7_�/��S|�n����`s��47j�:j?7z�n�yr���q�vIq��������C���=�cGz���n���؟]]DR��~</S��'%�{U�,����}y�O=^ք               �����pR � 