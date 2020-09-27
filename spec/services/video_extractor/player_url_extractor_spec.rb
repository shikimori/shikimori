describe VideoExtractor::PlayerUrlExtractor do
  describe '#call' do
    subject(:extract) { VideoExtractor::PlayerUrlExtractor.call html }

    context 'direct' do
      let(:html) { 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7' }
      it { is_expected.to eq Url.new(html).without_protocol.to_s }
    end

    context 'short', :vcr do
      context 'with_dash' do
        let(:html) { 'http://vk.com/video-42313379_167267838' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded' }
      end

      context 'without_dash' do
        let(:html) { 'http://vk.com/video98023184_165811692' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=98023184&id=165811692&hash=6d9a4c5f93270892' }
      end
    end

    context 'frame' do
      let(:html) { '<iframe width="607" src="' + extracted_url + '" height="360" frameborder="0"></iframe>' }
      let(:extracted_url) { '//vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded' }
      it { is_expected.to eq extracted_url }
    end

    context 'strip' do
      let(:html) { ' http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7 ' }
      it { is_expected.to eq Url.new(html.strip).without_protocol.to_s }
    end

    describe 'vk' do
      describe 'vk_1' do
        let(:html) { '<iframe src="http://vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2&hd=1" width="730" height="480" frameborder="0"></iframe>' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2' }
      end

      describe 'vk_2' do
        let(:html) { '<iframe src="http://vkontakte.ru/video_ext.php?oid=154832837&id=161773398&hash=3c74648f3d5c6cfc&hd=3" width="730" height="480" frameborder="0"></iframe>' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=154832837&id=161773398&hash=3c74648f3d5c6cfc' }
      end

      describe 'vk_3' do
        let(:html) { '<iframe src="http://vk.com/video_ext.php?oid=31645372&amp;id=163523215&amp;hash=3fba843aaeb2a8ae&amp;hd=1" width="730" height="480" frameborder="0"></iframe>' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=31645372&id=163523215&hash=3fba843aaeb2a8ae' }
      end

      describe 'remove misc parameters from url' do
        context '&hd=' do
          let(:html) { 'http://vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc&hd=1' }
          it { is_expected.to eq '//vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
        end

        context '&other=' do
          let(:html) { 'http://vk.com/video_ext.php?oid=36842689&qwe=vbn&id=163317311&hash=e446fa5312813ebc&zxc=1' }
          it { is_expected.to eq '//vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
        end

        context '&param' do
          let(:html) { 'http://vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc&param' }
          it { is_expected.to eq '//vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
        end
      end
    end

    # describe 'myvi' do
    #   describe do
    #     let(:html) { '<object style="height: 390px; width: 640px"><param name="movie" value="http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><embed src="http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480"></object>' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0' }
    #   end

    #   describe do
    #     let(:html) { '<object style="width: 640px; height: 390px"><param name="allowFullScreen" value="true"/><param name="allowScriptAccess" value="always" /><param name="movie" value="http://myvi.ru/ru/flash/player/pre/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30" /><param name="flashVars" value="kgzp=replace" /><embed src="http://myvi.ru/ru/flash/player/pre/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480" flashVars="kgzp=replace"></object>' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30' }
    #   end

    #   describe do
    #     let(:html) { '<iframe width="640" height="450" src="//myvi.tv/embed/html/oeBRkeha50wjXJIEU75wbYvUhlv4siaYE0KFla8kRgTHedQxAysFOs2B_yAWy3Tu80" frameborder="0" allowfullscreen></iframe>' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/oeBRkeha50wjXJIEU75wbYvUhlv4siaYE0KFla8kRgTHedQxAysFOs2B_yAWy3Tu80' }
    #   end

    #   describe do
    #     let(:html) { '<iframe width="640" height="450" src="http://myvi.ru/player/flash/o-yLxiEDfwHkdkERps0Ol8xsewC-jd-DQ-g5RR1EkMf2kwIfTBIScHSFJW4DvGJOu0hk]" frameborder="0" allowfullscreen></iframe>' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/o-yLxiEDfwHkdkERps0Ol8xsewC-jd-DQ-g5RR1EkMf2kwIfTBIScHSFJW4DvGJOu0hk' }
    #   end

    #   describe do
    #     let(:html) { '<iframe width="640" height="450" src="http://myvi.ru/player/flash/oPwYcE0DkIR7BuZ4Hjy-K97LXKJIgvwcsQQV3JDcss3LCRw294HoJ4fgXpSby1Q5lS2QxY125VvU1|http://myvi.ru/player/flash/oiLWME7qo9O3ragh7JC_fq2nr-f51DLt98_60sos3gbiY1ufb4hPA30whqpGE8VVjlVMzhdCsZgM1" frameborder="0" allowfullscreen></iframe>' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/oiLWME7qo9O3ragh7JC_fq2nr-f51DLt98_60sos3gbiY1ufb4hPA30whqpGE8VVjlVMzhdCsZgM1' }
    #   end

    #   describe do
    #     let(:html) { 'http://myvi.tv/embed/html/o2uWMvJRKqAyXG2EJUGGwUUKZwjleODmTYy0zGlks1-J5IO6Aexc_mKSgpudtZ7Zn0' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/o2uWMvJRKqAyXG2EJUGGwUUKZwjleODmTYy0zGlks1-J5IO6Aexc_mKSgpudtZ7Zn0' }
    #   end

    #   describe do
    #     let(:html) { 'http://myvi.ru/player/embed/html/preloader.swf?id=ooS23CgoxYNdHcm9FqwDb664Lbqhd1v7gyl7jDKc3O1xQ3-g0VOYjzoru3F35w6Ia0' }
    #     it { is_expected.to eq '//myvi.ru/player/embed/html/ooS23CgoxYNdHcm9FqwDb664Lbqhd1v7gyl7jDKc3O1xQ3-g0VOYjzoru3F35w6Ia0' }
    #   end
    # end

    describe 'myvi' do
      context 'full url', :vcr do
        let(:html) { 'https://www.myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh' }
        it { is_expected.to eq '//www.myvi.top/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
      end

      context 'embed url' do
        context 'myvi.top' do
          let(:html) { 'http://www.myvi.top/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
          it { is_expected.to eq '//www.myvi.top/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
        end

        context 'myvi.tv' do
          let(:html) { 'http://www.myvi.tv/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
          it { is_expected.to eq '//www.myvi.top/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
        end
      end
    end

    describe 'mail_ru' do
      describe do
        let(:html) { '<iframe src="http://api.video.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html" width="730" height="480" frameborder="0"></iframe>' }
        it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html' }
      end

      describe do
        let(:html) { '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="730" height="480" id="movie_name" align="middle"><param name="movie" value="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3"/><param name="flashvars" value="movieSrc=mail/bel_comp1/14985/15939&autoplay=0" /><param name="allowFullScreen" value="true" /><param name="AllowScriptAccess" value="always" /><!--[if !IE]>--><object type="application/x-shockwave-flash" data="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3" width="730" height="480"><param name="movie" value="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3"/><param name="flashvars" value="movieSrc=mail/bel_comp1/14985/15939&autoplay=0" /><param name="allowFullScreen" value="true" /><param name="AllowScriptAccess" value="always" /><!--<![endif]--><a href="http://www.adobe.com/go/getflash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player"/></a><!--[if !IE]>--></object><!--<![endif]--></object>' }
        it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/bel_comp1/14985/15939.html' }
      end

      describe do
        let(:html) { '<embed src="http://img.mail.ru/r/video2/player_v2.swf?par=http://video.mail.ru/mail/ol4ik87.87/1123/$3816" flashvars="orig=2" width="730" height="480" allowfullscreen="true" wmode="opaque"/>' }
        it { is_expected.to eq '//img.mail.ru/r/video2/player_v2.swf?par=http://video.mail.ru/mail/ol4ik87.87/1123/$3816' }
      end

      describe do
        let(:html) { '<iframe src="https://videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html" width="626" height="367" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>' }
        it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html' }
      end

      describe do
        let(:html) { 'http://my.mail.ru/mail/allenwolker91/video/11052/11071.html' }
        it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html' }
      end
    end

    # describe 'rutube' do
    #   describe do
    #     let(:html) { '<iframe width="730" height="480" src="//rutube.ru/video/embed/8c8bbdc632726555649d45c2c6a273c0" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/8c8bbdc632726555649d45c2c6a273c0' }
    #   end
    #
    #   describe do
    #     let(:html) { '<iframe width="720" height="405" src="//rutube.ru/play/embed/8c8bbdc632726555649d45c2c6a273c0?wmode=opaque&amp;autoStart=true" frameborder="0" webkitallowfullscreen="" mozallowfullscreen="" allowfullscreen="" id="video_frame"></iframe>' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/8c8bbdc632726555649d45c2c6a273c0' }
    #   end
    #
    #   describe do
    #     let(:html) { 'http://rutube.ru/tracks/2300012.html?v=8c8bbdc632726555649d45c2c6a273c0' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/8c8bbdc632726555649d45c2c6a273c0' }
    #   end
    #
    #   describe do
    #     let(:html) { 'http://rutube.ru/player.swf?hash=2ebdd7a1645cf60b0b60542689a54031' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/2ebdd7a1645cf60b0b60542689a54031' }
    #   end
    #
    #   describe do
    #     let(:html) { 'http://video.rutube.ru/?v=e9c211bd5a5f8bb848eef97ad21b046f' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/e9c211bd5a5f8bb848eef97ad21b046f' }
    #   end
    #
    #   describe do
    #     let(:html) { '<OBJECT width="730" height="480"><PARAM name="movie" value="http://video.rutube.ru/28c276bcec9a0619affa8e2443551b32"></PARAM><PARAM name="wmode" value="window"></PARAM><PARAM name="allowFullScreen" value="true"></PARAM><EMBED src="http://video.rutube.ru/28c276bcec9a0619affa8e2443551b32" type="application/x-shockwave-flash" wmode="window" width="730" height="480" allowFullScreen="true" ></EMBED></OBJECT>' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/28c276bcec9a0619affa8e2443551b32' }
    #   end
    #
    #   describe do
    #     let(:html) { 'https://rutube.ru/video/3c6027aa9c4ed58a565675ce80b91412/' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/3c6027aa9c4ed58a565675ce80b91412' }
    #   end
    #
    #   describe 'id converted to hash', :vcr do
    #     let(:html) { 'http://rutube.ru/play/embed/10259595' }
    #     it { is_expected.to eq '//rutube.ru/play/embed/8d2ba036c95314a62ce8a0fed801c81d' }
    #   end
    # end

    describe 'sibnet' do
      describe do
        let(:html) { '<iframe width="730" height="480" src="http://video.sibnet.ru/shell.php?videoid=1186077" frameborder="0" scrolling="no" allowfullscreen></iframe>' }
        it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1186077' }
      end

      describe do
        let(:html) { 'http://data10.video.sibnet.ru/13/88/40/1388407.flv' }
        it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1388407' }
      end

      describe do
        let(:html) { 'http://data17.video.sibnet.ru/71/08/710879.flv?st=WASnDgyViN6hucAYde9nlw&e=1349319000&format=mp4&start=0' }
        it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=710879' }
      end

      describe do
        let(:html) { 'http://data9.video.sibnet.ru/12/24/22/1224221.mp4?st=FRf7r1A0LxkpPBmuFybKXA&e=1375711000' }
        it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1224221' }
      end

      describe do
        let(:html) { 'https://video.sibnet.ru/rub/anime/video3589155-Gunjou_no_Magmel_1___Magmel_sinego_morya_1__russkie_subtitryi_/' }
        it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=3589155' }
      end

      describe 'remove misc parameters from url' do
        context 'digits only in videoid' do
          let(:html) { 'http://video.sibnet.ru/shell.php?videoid=1224221qwe' }
          it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1224221' }
        end

        context '&other=' do
          let(:html) { 'http://video.sibnet.ru/shell.php?videoid=1224221&zxc=1' }
          it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1224221' }
        end

        context '&param' do
          let(:html) { '//video.sibnet.ru/shell.php?videoid=1224221&param' }
          it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1224221' }
        end

        context '?param' do
          let(:html) { 'http://video.sibnet.ru/shell.php?autoplay=1&videoid=2677876' }
          it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=2677876' }
        end
      end
    end

    describe 'kiwi' do
      describe do
        let(:html) { '<iframe title="Kiwi player" width="730" height="480" src="http://v.kiwi.kz/v2/s3jf896ex7h9/" frameborder="0" allowfullscreen></iframe>' }
        it { is_expected.to eq '//v.kiwi.kz/v2/s3jf896ex7h9/' }
      end

      describe do
        let(:html) { '<object id="main_player_object" width="730" height="480"> <param name="wmode" value="opaque"/><param name="movie" value="http://p.kiwi.kz/static/player2/player.swf?config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F"> <param name="bgcolor" value="#000000"> <param name="allowFullScreen" value="true"> <param name="allowScriptAccess" value="always"> <embed wmode="opaque" id="main_player_embed" width="730" height="480" src="http://p.kiwi.kz/static/player2/player.swf" flashvars="config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true"> </object>' }
        it { is_expected.to eq '//p.kiwi.kz/static/player2/player.swf?config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F' }
      end
    end

    describe 'youtube' do
      describe do
        let(:html) { '<iframe width="730" height="480" src="http://www.youtube.com/embed/pOSilkJpCUI?feature=player_detailpage" frameborder="0" allowfullscreen></iframe>' }
        it { is_expected.to eq '//youtube.com/embed/pOSilkJpCUI' }
      end

      describe do
        let(:html) { '<object ><param name="wmode" value="opaque"/><param name="movie" value="http://www.youtube.com/v/CezgoEWr6U0?version=3&feature=player_detailpage"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><embed wmode="opaque" src="http://www.youtube.com/v/CezgoEWr6U0?version=3&feature=player_detailpage" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480"></object>' }
        it { is_expected.to eq '//youtube.com/embed/CezgoEWr6U0' }
      end

      describe do
        let(:html) { '<iframe width="730" height="480" src="//www.youtube.com/embed/pmLm4phNjB4?zxc=123" frameborder="0" allowfullscreen></iframe>' }
        it { is_expected.to eq '//youtube.com/embed/pmLm4phNjB4' }
      end
    end

    describe 'video.yandex' do
      let(:html) { '<iframe width="730" height="480" frameborder="0" src="http://video.yandex.ru/iframe/dashaset08/pwq0ljt7p4.5028/"></iframe>' }
      it { is_expected.to eq '//video.yandex.ru/iframe/dashaset08/pwq0ljt7p4.5028/' }
    end

    describe 'i.ua' do
      let(:html) { '<OBJECT width="730" height="480"><PARAM name="movie" value="http://i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead"></PARAM><EMBED src="http://i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead" type="application/x-shockwave-flash" width="730" height="480"></EMBED></OBJECT>' }
      it { is_expected.to eq '//i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead' }
    end

    describe 'flashx.tv' do
      let(:html) { '<IFRAME SRC="http://www.flashx.tv/embed-g5yfee5j0acc.html" FRAMEBORDER=0 MARGINWIDTH=0 MARGINHEIGHT=0 SCROLLING=NO WIDTH=852 HEIGHT=504></IFRAME>' }
      it { is_expected.to eq '//www.flashx.tv/embed-g5yfee5j0acc.html' }
    end

    describe 'vidbull.com' do
      let(:html) { '<IFRAME SRC="http://vidbull.com/embed-z8cyfxvok8nm-720x405.html" FRAMEBORDER=0 MARGINWIDTH=0 MARGINHEIGHT=0 SCROLLING=NO WIDTH=640 HEIGHT=360></IFRAME>' }
      it { is_expected.to eq '//vidbull.com/embed-z8cyfxvok8nm-720x405.html' }
    end

    describe 'mipix.eu' do
      let(:html) { '<iframe src="https://mipix.eu/translations/embed/274265" width="853" height="480" allowfullscreen frameborder="0"></iframe>' }
      it { is_expected.to eq '//mipix.eu/translations/embed/274265' }
    end

    # describe 'smotretanime.ru' do
    #   let(:html) { 'http://smotretanime.ru/catalog/anime-kod-gias-vosstavshiy-lelush-2-2522/11-seriya-3784/russkie-subtitry-522965' }
    #   it { is_expected.to eq '//smotretanime.ru/translations/embed/522965' }
    # end
    #
    # describe 'smotretanime.ru embed' do
    #   let(:html) { '<iframe src="https://smotretanime.ru/translations/embed/522965" width="853" height="526" allowfullscreen frameborder="0"></iframe>' }
    #   it { is_expected.to eq '//smotretanime.ru/translations/embed/522965' }
    # end

    # describe 'play.aniland.org' do
    #   let(:html) { 'http://play.aniland.org/2147401883?player=4' }
    #   it { is_expected.to eq '//play.aniland.org/2147401883?player=8' }
    # end

    # describe 'sovet romantica' do
    #   describe 'embed url' do
    #     let(:html) { 'https://sovetromantica.com/embed/episode_116_12-su' }
    #     it { is_expected.to eq '//sovetromantica.com/embed/episode_116_12-subtitles' }
    #   end
    #
    #   describe 'full url' do
    #     let(:html) { 'https://sovetromantica.com/anime/116-watashi-ga-motete-dousunda/episode_12-dub' }
    #     it { is_expected.to eq '//sovetromantica.com/embed/episode_116_12-dubbed' }
    #   end
    # end

    # describe 'animedia' do
    #   let(:html) { 'http://online.animedia.tv/embed/14678/1/8-zc' }
    #   it { is_expected.to eq '//online.animedia.tv/embed/14678/1/8' }
    # end

    # describe 'online.animaunt.ru' do
    #   let(:html) { 'http://online.animaunt.ru/Anime%20Online/All%20Anime/%5BAniMaunt.Ru%5D%20JoJo%E2%80%99s%20Bizarre%20Adventure/jojo1.01.mp4' }
    #   it { is_expected.to eq '//online.animaunt.ru/Anime%20Online/All%20Anime/%5BAniMaunt.Ru%5D%20JoJo%E2%80%99s%20Bizarre%20Adventure/jojo1.01.mp4' }
    # end

    describe 'gidfilm.ru' do
      let(:html) { 'http://gidfilm.ru/embed/234689' }
      it { is_expected.to eq '//gidfilm.ru/embed/234689' }
    end

    describe 'ok.ru' do
      let(:html) { 'https://ok.ru/live/815923404420' }
      it { is_expected.to eq '//ok.ru/videoembed/815923404420' }
    end

    # describe 'youmite' do
    #   let(:html) { 'https://video.youmite.ru/embed/JIzidma8NwTMu8m' }
    #   it { is_expected.to eq '//video.youmite.ru/embed/JIzidma8NwTMu8m' }
    # end

    # describe 'viuly.io' do
    #   let(:html) { 'https://viuly.io/embed/0148--neveroyatnoe-priklyuchenie-dzhodzho-rycari-zvzdnoy-pyli--anidub-150196' }
    #   it { is_expected.to eq '//viuly.io/embed/0148--neveroyatnoe-priklyuchenie-dzhodzho-rycari-zvzdnoy-pyli--anidub-150196' }
    # end

    # context 'stormo.xyz' do
    #   let(:html) { 'https://stormo.xyz/embed/415088/' }
    #   it { is_expected.to eq '//stormo.xyz/embed/415088/' }
    # end

    # context 'mediafile.online / iframedream.com' do
    #   let(:html) { 'https://mediafile.online/embed/212866' }
    #   it { is_expected.to eq '//mediafile.online/embed/212866' }
    # end

    context 'zedfilm.ru' do
      let(:html) { 'http://zedfilm.ru/785805' }
      it { is_expected.to eq '//gidfilm.ru/embed/785805' }
    end

    context 'wikianime.tv' do
      let(:html) { 'https://wikianime.tv/embed/?id=10' }
      it { is_expected.to eq '//wikianime.tv/embed/?id=10' }
    end

    context 'mp4upload.com' do
      context do
        let(:html) { 'https://www.mp4upload.com/embed-169qug77sszf.html' }
        it { is_expected.to eq '//mp4upload.com/embed-169qug77sszf.html' }
      end

      context do
        let(:html) { 'https://mp4upload.com/embed-169qug77sszf.html' }
        it { is_expected.to eq '//mp4upload.com/embed-169qug77sszf.html' }
      end
    end
  end
end
