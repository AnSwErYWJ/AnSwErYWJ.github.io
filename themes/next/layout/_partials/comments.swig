{% if page.comments %}
  <div class="comments" id="comments">
    {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
      <div class="ds-thread" data-thread-key="{{ page.path }}"
           data-title="{{ page.title }}" data-url="{{ page.permalink }}">
      </div>
    {% elseif theme.facebook_sdk.enable and theme.facebook_comments_plugin.enable %}
      <div class="fb-comments"
           data-href="{{ page.permalink }}"
           data-numposts="{{ theme.facebook_comments_plugin.num_of_posts }}">
      </div>
    {% elseif theme.disqus_shortname %}
      <div id="disqus_thread">
        <noscript>
          Please enable JavaScript to view the
          <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a>
        </noscript>
      </div>
    {% elseif theme.hypercomments_id %}
         <div id="hypercomments_widget"></div>
    {% elseif theme.gentie_productKey %}
         <div id="cloud-tie-wrapper" class="cloud-tie-wrapper"></div>
    {% elseif theme.youyan_uid %}
            <div id="uyan_frame"></div>
    {% elseif theme.changyan.appid and theme.changyan.appkey %}
      <div id="SOHUCS"></div>
    
    {% elseif theme.valine.enable and theme.valine.appid and theme.valine.appkey %}
      <script src="//cdn1.lncld.net/static/js/3.0.4/av-min.js"></script>
      <script src="//unjkp.com/valine/dist/Valine.min.js"></script>  //删除Valine核心代码库外链调用
      <script src="/js/src/Valine.min.js"></script>  //调用刚下载的本地文件以加速加载速度

      {% set valine_uri = '/js/src/Valine.min.js' %}  //这里改为从本地加载
      {% if theme.vendors.valine %}
        {% set valine_uri = theme.vendors.valine %}
      {% endif %}
      <script src="{{ valine_uri }}"></script>

      <script type="text/javascript">
        var GUEST = ['nick','mail','link'];
        var guest = '{{ theme.valine.guest_info }}';
        guest = guest.split(',').filter(function (item) {
          return GUEST.indexOf(item)>-1;
        });
        new Valine({
            el: '#comments' ,
            verify: {{ theme.valine.verify }},
            notify: {{ theme.valine.notify }},
            appId: '{{ theme.valine.appid }}',
            appKey: '{{ theme.valine.appkey }}',
            placeholder: '{{ theme.valine.placeholder }}',
            avatar:'{{ theme.valine.avatar }}',
            guest_info:['nick'] ,  //评论者只需要提供评论的昵称即可
            pageSize:'{{ theme.valine.pageSize }}' || 10,
        });
        //增加以下六行代码去除 power by valine
        var infoEle = document.querySelector('#comments .info');
        if (infoEle && infoEle.childNodes && infoEle.childNodes.length > 0){
          infoEle.childNodes.forEach(function(item) {
            item.parentNode.removeChild(item);
          });
        }
      </script>

    {% endif %}
  </div>
{% endif %}
