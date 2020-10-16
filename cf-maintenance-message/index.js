(function () {
    const CfAMaintenance={};

    CfAMaintenance.Icons={
        cog:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAABuklEQVRYhe3Wu2sUURQG8J/GTlPETtKIiEnto0gna5Mqq4UKakBBhPTRf0awsTVgYWFjYqdg7JPSEBCbxEcjuNm1mDtkd/bOnc3NWrkfnGLO6/tm7pwzwwQT5KGFDnrBOrie0+hkpoBrmOq7nsKVfyXgCTZwqc83F8mbr8Q38DBHVD+eOnzMP3Abd7Hb5y9tJ8Qe4GfwdbGSS/4oNKgSHdW6QdiR8W4M5KWt5Qi4gL0xkH/DbI4AuDUGAYspgqYpOF3j30Ib08FuYrsm92yK4ETEt4irirFq4VyEfAHfK/4ZfDA8ol/wJtR9DjlJHEg/0qVEbbuh9k8TuYYGPZxJ1E6PUD+A3FVch9iRJhET0GmouZGItRpqu1VHTPECLit2/xLOV+LbIWe/4p/BR4PfDPiKdcVLuIm3DSIHcE/8HKtj2A7CYrn3UwSnGgTs1fjn8HqUO8DvEfOGMKtYo8fdhPu4mCNgbQzkpa3XkaTG8JXI3Gagh5e5xSsON+MvLCu+7TuG73I3xO4ofl5K/2q+9gLLeG/wl+t5RMCLvvh8qHl8XPI6rEYEPMtplLuKNxVHU+IAnzJ7TfCf4y+1kepxyfi12AAAAABJRU5ErkJggg==",
        alert:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAABV0lEQVRYhe2VP0oDQRjFfwQi0UqNpRDwAoI3MJhb6AkEGz2FnsLcQk8ggkHF0qiNYGEsLNTCMBaZgXHy7fzZ7E61D16xM+/73rc7w1toUB594FGzn9t8DZgASnOi17LhzDI3PM1lvgl8CQN8A70cAwwFc8Pzus23galngCmwU+cAlx5zw4u6zHcjzA0HVZu3gJFlcAe0rf22XjP7I11TGQ74/4ZXguba0exXZb4EjJ3m94LuwdG8AJ1Q85jPdARsOWvLgm7Fee4BhxH9vVgF3pm/ZK+C9k3QfQDriwwgRa5p7OKzQFs6oosiVwE/gv63QFs6on2Rq5gdj8FGQDtMNQ9FbiqTIzomclMZHdGDyIZdq6YbWROM6BZwE9nMRUzNLYHscSO36gEUnojuMIvP2EZljkDhieiThCaL8lga4DnjAE/G1L4Q0rlmxR7zv906ONZeDRoA8AcUklEqQcSO3AAAAABJRU5ErkJggg==",
        check:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAABuklEQVRYhe3Wu2sUURQG8J/GTlPETtKIiEnto0gna5Mqq4UKakBBhPTRf0awsTVgYWFjYqdg7JPSEBCbxEcjuNm1mDtkd/bOnc3NWrkfnGLO6/tm7pwzwwQT5KGFDnrBOrie0+hkpoBrmOq7nsKVfyXgCTZwqc83F8mbr8Q38DBHVD+eOnzMP3Abd7Hb5y9tJ8Qe4GfwdbGSS/4oNKgSHdW6QdiR8W4M5KWt5Qi4gL0xkH/DbI4AuDUGAYspgqYpOF3j30Ib08FuYrsm92yK4ETEt4irirFq4VyEfAHfK/4ZfDA8ol/wJtR9DjlJHEg/0qVEbbuh9k8TuYYGPZxJ1E6PUD+A3FVch9iRJhET0GmouZGItRpqu1VHTPECLit2/xLOV+LbIWe/4p/BR4PfDPiKdcVLuIm3DSIHcE/8HKtj2A7CYrn3UwSnGgTs1fjn8HqUO8DvEfOGMKtYo8fdhPu4mCNgbQzkpa3XkaTG8JXI3Gagh5e5xSsON+MvLCu+7TuG73I3xO4ofl5K/2q+9gLLeG/wl+t5RMCLvvh8qHl8XPI6rEYEPMtplLuKNxVHU+IAnzJ7TfCf4y+1kepxyfi12AAAAABJRU5ErkJggg=="
    }

    CfAMaintenance.Settings={
        scheduledMaintenance: "00 1 1 * *",
        maintenanceDurationInHours:1,
        maintenanceNoticeDurationInHours:2,
        debugTimeSpeed:1
    }

    CfAMaintenance.cronToDate=function(cron){
        later.date.UTC();
        const s = later.parse.cron(cron, false);
        const scheduler=  later.schedule(s);
        return scheduler.next(0);
    }

    CfAMaintenance.showMaintenanceMessage=function(icon,type,message){
        const body=document.querySelector("body");
        let maintenanceEl=body.querySelector("#cf-a-maintenance");
        if(maintenanceEl){
            console.log("Clear maintenance message");
            maintenanceEl.innerHTML="";
        }else{
            console.log("Create new maintenance message");
            maintenanceEl=document.createElement("div");
            maintenanceEl.setAttribute("id","cf-a-maintenance");
            maintenanceEl.addEventListener("click",function(ev){
                maintenanceEl.style.display="none";
            });
            body.appendChild(maintenanceEl);
        }

        if(type&&!maintenanceEl.className!=type){
            maintenanceEl.className=type;
            maintenanceEl.style.display="flex";
        }

        console.info(message);

        const iconEl=document.createElement("img");
        iconEl.setAttribute("src",icon);
        maintenanceEl.appendChild(iconEl);        

        const messageEl=document.createElement("span");
        messageEl.innerHTML=message;
        maintenanceEl.appendChild(messageEl);
        
    
    }


    CfAMaintenance.getTime=function(){
        let date=Date.now();

        if(CfAMaintenance.Settings.debugTimeSpeed>1){
            if(!CfAMaintenance.prevDate)CfAMaintenance.prevDate=date;
            let virtualDate= CfAMaintenance.prevDate+(date- CfAMaintenance.prevDate)*CfAMaintenance.Settings.debugTimeSpeed;
            date=virtualDate;
        }

        return date;
    }


    CfAMaintenance.showScheduledMaintenanceMessage=function(){
        const nextMaintenance=CfAMaintenance.cronToDate(CfAMaintenance.Settings.scheduledMaintenance);
        const currentDate=CfAMaintenance.getTime();

        
        let delta=(nextMaintenance-currentDate)/1000;
        const sign=Math.sign(delta);
        delta=Math.abs(delta);
        let deltaH=Math.floor(delta/  3600);
        let deltaM=Math.floor((delta-(deltaH* 3600) )/ 60);
        if(sign<=0){
            if(deltaH<CfAMaintenance.Settings.maintenanceDurationInHours){
                CfAMaintenance.showMaintenanceMessage(CfAMaintenance.Icons.cog,"cf-a-maintenance-inprogress","Maintenance in progress..."  );
                if(localStorage)localStorage.setItem('cf-a-maintenance', '1');
                setTimeout(CfAMaintenance.showScheduledMaintenanceMessage,Math.max(1,1000/CfAMaintenance.Settings.debugTimeSpeed));
                return;
            }else{
                const mFlag = localStorage.getItem('cf-a-maintenance');
                if(localStorage&&mFlag&&mFlag=="1"){
                    CfAMaintenance.showMaintenanceMessage(CfAMaintenance.Icons.check,"cf-a-maintenance-completed","Maintenance completed! All services should be back to normal."  );
                    localStorage.removeItem('cf-a-maintenance');
                }  
            }
        }else{
            if(deltaH<CfAMaintenance.Settings.maintenanceNoticeDurationInHours){
                CfAMaintenance. showMaintenanceMessage(CfAMaintenance.Icons.alert,"","Scheduled unattended maintenance will start in "+  deltaH+" hours and "+deltaM+" minutes. <br />Slowdowns and hiccups are expected during this process.");
                if(localStorage)localStorage.setItem('cf-a-maintenance', '1');
                setTimeout(CfAMaintenance.showScheduledMaintenanceMessage,Math.max(1,(1000*60)/CfAMaintenance.Settings.debugTimeSpeed)  );
                return;
            }
        }  
        setTimeout(CfAMaintenance.showScheduledMaintenanceMessage,Math.max(1,(20*60*1000)/CfAMaintenance.Settings.debugTimeSpeed));
    }

    if (document. readyState === 'complete') {
        CfAMaintenance.showScheduledMaintenanceMessage();
    }else{
        document.addEventListener("DOMContentLoaded", function(){
            CfAMaintenance.showScheduledMaintenanceMessage();
        });
    }
}())